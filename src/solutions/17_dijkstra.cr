class Aoc2023::SeventeenDijkstra < Aoc2023::Solution
  def self.day_int
    17
  end

  def self.variant
    "dijkstra"
  end

  def parse(lines)
    map = Array(Array(Int32)).new
    lines.map do |line|
      map << line.chars.map(&.to_i32)
    end
    Map.new(map)
  end

  def part1(lines)
    map = parse lines
    start = {x: 0, y: 0}
    stop = {x: map.max_x, y: map.max_y}

    # coord, dist, dir, streak, parent
    visited = [] of Tuple(Coord, Int32, Coord, Int32, Coord | Nil)
    unvisited = [] of Tuple(Coord, Int32, Coord, Int32, Coord | Nil)
    map.each do |c, t|
      unvisited << { c, Map::UNREACHABLE, {x: 0, y: 0}, 0, nil }
    end
    cur = { start, 0, {x: 0, y: 0}, 0, nil }
    loop do
      nb = map.neighbors(cur[0])
      nb_c = nb.map(&.first)
      u_nb = unvisited.select { |u| u[0].in?(nb_c) }
      u_nb.each do |n|
        dir = map.diff n[0], cur[0]
        d = cur[1] + map.get! n[0]
        if d < n[1]
          streak = cur[3]
          streak2 = dir == cur[2] ? streak + 1 : 1
          if streak2 <= 3
            n2 = { n[0], d, dir, streak2, cur[0] }
            unvisited[unvisited.index! { |u| u[0] == n[0] }] = n2
          end
        end
      end
      visited << cur
      unvisited.reject! { |u| u[0] == cur[0] }
      cur = unvisited.min_by { |u| u[1] }
      if cur[0] == stop
        break
      end
    end
    path = [ cur ]
    loop do
      parent = path.first[4]
      break if parent.nil?
      path.unshift visited.find! { |v| v[0] == parent }
    end
    resolver = ->(c : Coord, t : Int32 | Nil) : Char | Nil {
      path_el = path.find { |e| e[0] == c }
      if path_el
        case path_el[2]
        when Map::NORTH
          '^'
        when Map::EAST
          '>'
        when Map::SOUTH
          'v'
        when Map::WEST
          '<'
        else 
          'o'
        end
      else
        t.to_s.chars[0]
      end
    }
    map.draw resolver: resolver
    puts ""
    cur[1]
  end

  def part2(lines)
  end
end
