class Aoc2023::Fourteen < Aoc2023::Solution
  def part1(lines)
    map = Parsers.map(lines)
    tilt map, Map::NORTH
    load map
  end

  def part2(lines)
    map = Parsers.map(lines)

    # 300 is a magical number that works for my input. TODO: refactor to keep cycling if repeat not found
    loads = 300.times.map do |i|
      debug i
      cycle map
      load(map)
    end.to_a

    loads.each.with_index do |load, i|
      debug_line i, load
    end

    # travel up to the load from the beginning of the list,
    # looking back/forward to see if we are at a point where the pattern repeats
    repeat = -1
    period = -1
    loads.each.with_index do |load, i|
      (i+1).times do |n|
        next unless n > 0
        load_1 = loads[(i-n)..i]
        load_2 = loads[(i+1)..(i+1+n)]
        #debug_line load_1, load_2
        if load_1 == load_2
          repeat = i
          period = n + 1
          break
        end
      end
      break if repeat > -1
    end

    raise "repeat not found" unless repeat > -1

    cycles = 1_000_000_000

    start = repeat - period + 1
    debug start, period

    repeat_pat = loads[start..(start + period - 1)]
    debug repeat_pat

    offset = (cycles - start) % period - 1
    repeat_pat[offset]
  end

  def load(map)
    map.find_all('O').sum do |c|
      map.max_y - c[:y] + 1
    end
  end

  def tilt(map, dir)
    # have to iterate from different directions so stones which can freely roll are rolled first
    y1, y2, x1, x2 =
      case dir
      when Map::NORTH
        {map.min_y, map.max_y, map.min_x, map.max_x}
      when Map::WEST
        {map.min_y, map.max_y, map.min_x, map.max_x}
      when Map::SOUTH
        {map.max_y, map.min_y, map.min_x, map.max_x}
      else #when Map::EAST
        {map.min_y, map.max_y, map.max_x, map.min_x}
      end
    y1.to(y2) do |y|
      x1.to(x2) do |x|
        c = {x: x, y: y}
        t = map.get c
        next unless t == 'O'
        loop do
          c2 = map.add c, dir
          t2 = map.get c2
          break unless t2 == '.'
          map.swap c, c2
          c = c2
        end
      end
    end
  end

  def cycle(map)
    tilt map, Map::NORTH
    tilt map, Map::WEST
    tilt map, Map::SOUTH
    tilt map, Map::EAST
  end
end
