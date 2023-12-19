class Aoc2023::Eighteen < Aoc2023::Solution
  def part1(lines)
    plan = Parsers.pattern(lines, /(\w) (\d+) \(#(.{6})\)/) do |m|
      { m[1].chars[0], m[2].to_i32 }
    end
    map = Map(Char).new
    digger = {x: 0, y: 0}
    map.set digger, '#'
    flood_point = {x: 1, y: 1}
    plan.each do |(dir, len)|
      offset = case dir
               when 'U' then Map::NORTH
               when 'R' then Map::EAST
               when 'D' then Map::SOUTH
               else Map::WEST #when 'L'
               end
      len.times do
        digger = map.add digger, offset
        map.set digger, '#'
      end
    end
    map.flood({x: 1, y: 1}, '#')
    map.find_all('#').size
  end

  def part2(lines)
    # parse the input with new rules
    plan = Parsers.pattern(lines, /(\w) (\d+) \(#(.{6})\)/) do |m|
      color = m[3]
      dir = case color.chars[-1].to_i32
            when 0 then 'R'
            when 1 then 'D'
            when 2 then 'L'
            else 'U' #when 3
            end
      len = color[0..-2].to_i(16)
      {dir, len}
    end
    # follow plan to generate corners of loop
    corners = [] of Coord
    corners << {x: 0, y: 0}
    plan.each do |(dir, len)|
      corner = corners.last
      offset = case dir
               when 'U' then Map::NORTH
               when 'R' then Map::EAST
               when 'D' then Map::SOUTH
               else Map::WEST #when 'L'
               end
      corner = Map.add corner, Map.product(offset, len)
      corners << corner
    end

    # build a list of vertical edges
    v_edges = [] of Tuple(Coord, Coord)
    corners.each_cons_pair do |a,b|
      next if a[:y] == b[:y]
      v_edges << {a, b}
    end

    # use the x/y of all corners to build a grid of differently-sized rects,
    # using the number of vertical edges on the left to determine if it's a dig rect or not
    xa = corners.map { |c| c[:x] }.sort.uniq
    ya = corners.map { |c| c[:y] }.sort.uniq
    dig = Hash(Coord, Bool).new
    ya.each_cons_pair.with_index do |(y1, y2), yi|
      xa.each_cons_pair.with_index do |(x1, x2), xi|
        p = { x: x1 + 1, y: y1 + 1 }
        v_edges_to_left = v_edges.count do |(a,b)|
          p[:y].in?(a[:y].to(b[:y])) && p[:x] < a[:x]
        end
        dig[{x: xi, y: yi}] = v_edges_to_left.odd?
      end
    end

    # use the precomputed dig grid to total up rect sizes.
    # a rect always counts its own top and left edge, and consequently its top-left corner.
    # if the right rect isn't a dig, take its shared edge (and the top-right corner).
    # if the down rect isn't a dig, take its shared edge (and the bottom-left corner).
    # if both edges are taken, the bottom-right corner is also taken.
    # because the corners are taken when edges are taken,
    # we must dedup corners, otherwise we'll overcount.
    total = 0_i128
    ya.each_cons_pair.with_index do |(y1, y2), yi|
      xa.each_cons_pair.with_index do |(x1, x2), xi|
        next unless dig.fetch({x: xi, y: yi}, false)
        w = (x2.to_i128 - x1)
        h = (y2.to_i128 - y1)
        right = dig.fetch({x: xi + 1, y: yi}, false)
        down = dig.fetch({x: xi, y: yi + 1}, false)
        w += 1 if !right
        h += 1 if !down
        size = w * h
        # dedup corners
        #   likely to happen. 2 will count its top-right corner even though 1 already counted it
        #   ### #1#
        #   #.# 2.#
        if !right
          right_up = dig.fetch({x: xi + 1, y: yi - 1}, false)
          size -= 1 if right_up
        end
        #   likely doesn't happen, but to be safe. 1 takes all its edges and 2 takes its top-left corner as it should.
        #   #.. 1..
        #   .#. .2.
        if !right && !down
          right_down = dig.fetch({x: xi + 1, y: yi + 1}, false)
          size -= 1 if right_down
        end
        total += size
      end
    end
    total
  end
end
