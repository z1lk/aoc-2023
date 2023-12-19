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
      beams = beams.flat_map do |c,t|
        next unless energy.in_bounds?(c)
        next if paths.includes?({c,t})
        paths << {c,t}
        energy.set(c, '#')
        case map.get c
        when '/'
          case t
          when '>' then beam(c, '^')
          when 'v' then beam(c, '<')
          when '<' then beam(c, 'v')
          when '^' then beam(c, '>')
          end
        when '\\'
          case t
          when '>' then beam(c, 'v')
          when 'v' then beam(c, '>')
          when '<' then beam(c, '^')
          when '^' then beam(c, '<')
          end
        when '|'
          case t
          when '>' then [beam(c, 'v'), beam(c, '^')]
          when 'v' then beam(c, 'v')
          when '<' then [beam(c, 'v'), beam(c, '^')]
          when '^' then beam(c, '^')
          end
        when '-'
          case t
          when '>' then beam(c, '>')
          when 'v' then [beam(c, '>'), beam(c, '<')]
          when '<' then beam(c, '<')
          when '^' then [beam(c, '>'), beam(c, '<')]
          end
        else # when '.'
          beam(c, t)
        end
      end.compact
      break unless beams.any?
    end
    energy.find_all('#').size
  end

  # propagate the beam
  def beam(c, t)
    dir = case t
          when '>' then E
          when 'v' then S
          when '<' then W
          when '^' then N
          else raise "bad dir"
          end
    { Map.add(c, dir), t }
  end
end
