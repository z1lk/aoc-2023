class Aoc2023::Five < Aoc2023::Solution
  alias Range64 = Range(Int64, Int64)
  def parse(lines)
    seeds = [] of Int64
    maps = Hash(String, Hash(Range64, Range64)).new

    Parsers.groups(lines).each do |group|
      case header = group.shift
      when /seeds:/
        seeds = header.split(": ")[1].split.map(&.to_i64)
      when /map:/
        md = header.match(/(\w+)-to-(\w+) map:/)
        raise "bad group header" unless md
        source = md[1]
        dest = md[2]
        key = "#{source}-to-#{dest}"
        maps[key] = Hash(Range64, Range64).new #(default)
        group.each do |line|
          dest_0, source_0, len = line.split.map(&.to_i64)
          source_r = source_0..(source_0+len-1)
          dest_r = dest_0..(dest_0+len-1)
          maps[key][source_r] = dest_r
        end
      else
        raise "unrecognized group"
      end
    end

    {seeds, maps}
  end

  CATS = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  def part1(lines)
    seeds, maps = parse lines
    seed_locations = Hash(Int64, Int64).new
    seeds.each do |seed|
      seed_locations[seed] = CATS.each_cons_pair.reduce(seed) do |value, (a, b)|
        map = maps["#{a}-to-#{b}"]
        if source = map.keys.find { |k| k.covers?(value) }
          dest = map[source]
          offset = value - source.begin
          value = dest.begin + offset
        else
          # "source numbers that aren't mapped correspond to the same destination number"
        end
        value
      end
    end
    seed_locations.values.min
  end

  def part2(lines)
    seeds, maps = parse lines

    # convert seeds to range format for part 2
    seed_ranges = seeds.each_slice(2).map do |(a, b)|
      (a..(a+b-1))
    end

    # put each seed range through the mappings similar to part 1
    loc_ranges = seed_ranges.flat_map do |seed_range|
      # rather than reducing a seed integer value, reduce the seed_range into multiple ranges
      CATS.each_cons_pair.reduce([seed_range]) do |ranges, (a, b)|
        map = maps["#{a}-to-#{b}"]
        sources = map.keys
        new_ranges = [] of Range64
        # for each range, split it into multiple ranges according to where it overlaps with
        # the sources in the mapping. this accounts for the fact that values within a range
        # can be mapped differently, without having to iterate on every single value in the range.
        ranges.each do |range|
          cuts = sources.map(&.begin) + sources.map { |s| s.end+1 }
          cuts.uniq!.sort!
          split = split_range(range, cuts)
          split_offset = split.map do |s|
            next s unless key = map.keys.find { |k| k.covers?(s.begin) }
            offset = map[key].begin - key.begin
            (s.begin + offset)..(s.end + offset)
          end
          new_ranges.concat(split_offset)
        end
        new_ranges.uniq
      end
    end

    # splitting ranges accounted for all paths through the mapping.
    # the lowest location is necessarily the lowest #begin of the all location ranges.
    loc_ranges.map(&.begin).min
  end

  # splits range into multiple ranges at cut points
  def split_range(a, cuts)
    cuts = cuts.select { |c| a.covers?(c) }
    return [a] if cuts.none?
    [
      (a.begin..cuts[0]),
      *cuts.each_cons_pair.to_a.map { |(a,b)| a..(b-1) },
      (cuts[-1]..a.end)
    ]
  end
end
