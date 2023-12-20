class Aoc2023::Nineteen < Aoc2023::Solution
  alias Ratings = Hash(String, Int32)

  def parse(lines)
    { parse_workflows(lines), parse_ratings(lines) }
  end

  def parse_workflows(lines)
    workflows =
      Hash(
        String, # name
        Array( # rules
          Tuple( # rule
            String, # rating key
            Range(Int32, Int32), # range
            String # new wf
          ) | String # wf to go straight to w/o test
        )
      ).new

    Parsers.groups(lines)[0].each do |s|
      name, tests = s.split("{")
      tests = tests[0..-2] # remove closing "}"
      workflows[name] = tests.split(",").map do |test|
        if test.matches?(/:/)
          cond, wf = test.split(":")
          rating, op, val = cond.match!(/^(\w+)(>|<)(\d+)$/).captures
          raise "no capture rating " if rating.nil?
          raise "no capture val" if val.nil?
          val = val.to_i32
          case op
          when ">" then { rating, (val+1)..4000, wf }
          # Each of the four ratings (x, m, a, s) can have an integer value ranging from a minimum of 1 to a maximum of 4000
          when "<" then { rating, 1..(val-1), wf }
          else raise "bad op #{op}"
          end
        else
          test
        end
      end
    end

    workflows
  end

  def parse_ratings(lines)
    Parsers.groups(lines)[1].map do |ratings_s|
      ratings_s = ratings_s[1..-2]
      ratings_s.split(",").reduce(Ratings.new) do |h,s|
        rating, val = s.split("=")
        h[rating] = val.to_i32
        h
      end
    end
  end

  def work(workflows, ratings)
    wf = "in"
    until wf == "A" || wf == "R"
      tests = workflows[wf]
      wf2 = nil
      tests.each do |test|
        if test.is_a?(String)
          wf2 = test
          break
        end
        rating, range, new_wf = test
        if ratings[rating].in?(range)
          wf2 = new_wf
          break
        end
      end
      raise "wf2 didn't change" if wf2 == wf
      raise "wf2 nil" if wf2.nil?
      wf = wf2
    end
    wf
  end

  def part1(lines)
    workflows, ratings_a = parse lines
    ratings_a.select do |ratings|
      work(workflows, ratings) == "A"
    end.sum do |rating|
      rating.values.sum
    end
  end

  def part2(lines)
    workflows, ratings_a = parse lines

    # pull all the ranges out from `parse_workflows`
    rating_ranges = Hash(String, Array(Range(Int32, Int32))).new
    rating_ranges["x"] = [] of Range(Int32, Int32)
    rating_ranges["m"] = [] of Range(Int32, Int32)
    rating_ranges["a"] = [] of Range(Int32, Int32)
    rating_ranges["s"] = [] of Range(Int32, Int32)
    workflows.each do |wf, tests|
      tests.each do |test|
        if test.is_a?(String)
          next # A, R, wf
        else
          rating, range, wf = test
          rating_ranges[rating] << range
        end
      end
    end

    # cut ranges where they overlap to get every range that has a distinct path through the workflows
    rating_ranges2 = Hash(String, Array(Range(Int32, Int32))).new
    rating_ranges.each do |rating, ranges|
      rating_ranges2[rating] = [] of Range(Int32, Int32)
      all_beg = ranges.map(&.begin)
      # add 1 to ends so they function correctly as the start of ranges
      all_end = ranges.map { |r| r.end + 1 }
      all = [*all_beg, *all_end].sort.uniq
      all.each_cons_pair do |a, b|
        # b-1 to undo +1 on ends earlier
        rating_ranges2[rating] << (a..(b-1))
      end
    end

    # take every combination of distinct x/m/a/s ranges and see if it is accepted or rejected
    accepts = 0_i128
    rating_ranges2["x"].each do |x|
      rating_ranges2["m"].each do |m|
        rating_ranges2["a"].each do |a|
          rating_ranges2["s"].each do |s|
            # all values within each range give the same result, so use the first value (`begin`)
            ratings = {"x" => x.begin, "m" => m.begin, "a" => a.begin, "s" => s.begin}
            if work(workflows, ratings) == "A"
              accepts += 1_i128 * x.size * m.size * a.size * s.size
            end
          end
        end
      end
    end
    accepts
  end
end
