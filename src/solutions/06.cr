require "big"

class Aoc2023::Six < Aoc2023::Solution
  def parse(lines)
    m1 = lines[0].match(/Time:\s+(.*)$/)
    m2 = lines[1].match(/Distance:\s+(.*)$/)
    raise "bad input" if m1.nil? || m2.nil?
    durs = m1[1].split.map(&.to_i32)
    dists = m2[1].split.map(&.to_i32)
    durs.zip(dists).to_h
  end

  def part1(lines)
    races = parse lines
    races.map do |dur, dist|
      dur.times.count do |t|
        t * (dur - t) > dist
      end
    end.product
  end

  def part2(lines)
    races = parse lines
    dur = races.keys.map(&.to_s).join.to_i64
    best = races.values.map(&.to_s).join.to_i64

    # quadratic equation:
    # dist = t * (dur-t)
    # dist = dur*t + -t**2
    # t**2 - dur*t + dist = 0
    # use quadratic formula for: t**2 - dur*t + dist = 0
    # where dist = max. zeroes are where t gives "best" dist
    #   (-b +- sqrt(b**2 - 4ac)) / 2a
    a = 1
    b = BigInt.new(-1 * dur)
    c = BigInt.new(best)
    rt = Math.sqrt(b**2 - (4*a*c))
    max = ((-1*b) + rt) / 2*a
    min = ((-1*b) - rt) / 2*a
    # edge case where min or max are not decimals, ceil/floor would give the same number
    first = min.ceil.to_i64
    last = max.floor.to_i64
    last - first + 1
  end
end
