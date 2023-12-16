class Aoc2023::Sixteen < Aoc2023::Solution
  E = Map::EAST
  S = Map::SOUTH
  W = Map::WEST
  N = Map::NORTH

  def part1(lines)
    map = Parsers.map lines
    energize map, {x: 0, y: 0}, '>'
  end

  def part2(lines)
    map = Parsers.map lines
    energies = [] of Int32
    map.min_x.to(map.max_x) do |x|
      energies << energize map, { x: x, y: 0 }, 'v'
      energies << energize map, { x: x, y: map.max_y }, '^'
    end
    map.min_y.to(map.max_y) do |y|
      energies << energize map, { x: 0, y: y }, '>'
      energies << energize map, { x: map.max_x, y: y }, '<'
    end
    energies.max
  end

  def energize(map, start, char)
    energy = map.clone
    energy.each do |c,t|
      energy.set c, '.'
    end
    beams = [] of Tuple(Coord, Char)
    beams << { start, char }
    # paths keeps track of when a beam has crossed a cell in a particular direction.
    # once a path has been energized we don't need to do it again.
    paths = [] of Tuple(Coord, Char)
    loop do
      #resolver = ->(c : Coord, t : Char | Nil) : Char | Nil {
      #  c_beams = beams.select { |(bc, bt)| bc == c }
      #  return c_beams.size.to_s.chars.first if c_beams.size > 1
      #  return c_beams[0][1] if c_beams.size == 1
      #  t
      #}
      #sleep 0.05
      #map.draw resolver: resolver
      beams2 = [] of Tuple(Coord, Char)
      beams.each do |c,t|
        next unless energy.in_bounds?(c)
        next if paths.includes?({c,t})
        paths << {c,t}
        energy.set(c, '#')
        cont = false
        case map.get c
        when '/'
          case t
          when '>' then beams2 << { map.add(c, N), '^' }
          when 'v' then beams2 << { map.add(c, W), '<' }
          when '<' then beams2 << { map.add(c, S), 'v' }
          when '^' then beams2 << { map.add(c, E), '>' }
          end
        when '\\'
          case t
          when '>' then beams2 << { map.add(c, S), 'v' }
          when 'v' then beams2 << { map.add(c, E), '>' }
          when '<' then beams2 << { map.add(c, N), '^' }
          when '^' then beams2 << { map.add(c, W), '<' }
          end
        when '|'
          case t
          when '>' then beams2.push({ map.add(c, S), 'v' }, { map.add(c, N), '^' })
          when 'v' then cont = true
          when '<' then beams2.push({ map.add(c, S), 'v' }, { map.add(c, N), '^' })
          when '^' then cont = true
          end
        when '-'
          case t
          when '>' then cont = true
          when 'v' then beams2.push({ map.add(c, E), '>' }, { map.add(c, W), '<' })
          when '<' then cont = true
          when '^' then beams2.push({ map.add(c, E), '>' }, { map.add(c, W), '<' })
          end
        when '.' then cont = true
        end
        if cont
          dir = case t
                when '>' then E
                when 'v' then S
                when '<' then W
                when '^' then N
                else raise "bad dir"
                end
          beams2 << { map.add(c, dir), t }
        end
      end
      break unless beams2.any?
      beams = beams2
    end
    energy.find_all('#').size
  end
end
