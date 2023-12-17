class Aoc2023::Seventeen < Aoc2023::Solution
  DIRS = [
    {x: 1, y: 0},
    {x: 0, y: 1},
    {x: -1, y: 0},
    {x: 0, y: -1}
  ]

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

    dist_precomp = Hash(NamedTuple(x: Int32, y: Int32), Int32).new
    map.min_x.to(map.max_x) do |x|
      map.min_y.to(map.max_y) do |y|
        c = {x: x, y: y}
        dist_precomp[c] = map.dist(c, stop)
      end
    end

    # coord, loss, dir, streak, path
    queue = [] of Tuple(Coord, Int32, Coord, Int32, Array(Coord))

    queue << { start, 0, {x: 0, y: 0}, 0, [] of Coord }

    best = Map::UNREACHABLE

    # compute straight to the end, going DRDRDR... as our starting best.
    straight = 0
    coord = start
    dir = { x: 0, y: 0 }
    until coord == stop
      dir = dir == Map::SOUTH ? Map::EAST : Map::SOUTH
      nex = map.add coord, dir
      loss = map.get! nex
      straight += loss
      coord = nex
    end
    best = straight
    debug_line "straight", best

    # cache coord, dir, streak = loss
    #cache = Hash(Tuple(Coord, Coord, Int32), Int32).new
    # cache coord, dir = array(streak, loss)
    cache = Hash(Tuple(Coord, Coord), Array(Int32)).new
    map.each do |c,t|
      Map::ADJ.each do |dir|
        cache[{c,dir}] = [Map::UNREACHABLE, Map::UNREACHABLE, Map::UNREACHABLE]
      end
    end

    i = 0_i128
    until queue.empty?
      #queue.sort_by! { |q| [map.dist(q[0], stop), q[1]] }# if i % 100_000 == 0
      #cur = queue.shift
      #cur = queue.pop
      cur = queue.min_by { |q| [dist_precomp[q[0]], q[1]] }
      queue.delete cur

      i += 1
      if i % 100_000 == 0
        debug_line "queue", queue.size 
        debug ""
        debug "best=#{best}"
        #debug_line cur[0], cur[1]
      end
      if cur[0] == stop
        if cur[1] < best
          best = cur[1] 
          queue.reject! do |q|
            next true if q[1] >= best
            loss_left = best - q[1]
            if dist_precomp[q[0]] > loss_left
              #draw map, cur
              next true
            end
          end
        end
        next
      end
      #next if cur[1] >= best

      opp = case cur[2]
            when Map::NORTH then Map::SOUTH
            when Map::EAST then Map::WEST
            when Map::SOUTH then Map::NORTH
            when Map::WEST then Map::EAST
            end
      neighbors = DIRS.-([opp]).map do |dir|
        n = map.add(cur[0],dir)
        { n, map.get(n), dir }
      end
      #map.neighbors(cur[0]).each do |(c,t)|
      neighbors.each do |(c,t,dir)|
        next if c.in?(cur[4]) # neighbor is in path
        next if t.nil? # outside map
        #next if map.add(cur[2], dir) == { x: 0, y: 0 } # went way we came
        loss = cur[1] + t
        next unless loss < best
        #dir = map.diff c, cur[0]
        streak = dir == cur[2] ? cur[3] + 1 : 1
        next if streak > 3

        #key = {c, dir, streak}
        #cached = cache.fetch(key,nil) 
        #cached_keys = cache.keys.select { |k| k[0] == c && k[1] == dir && k[2] <= streak }
        #bad = cached_keys.any? { |k| cache[k] < loss }
        #if cached && loss > cached
        #if bad # cached && cached < loss
        #  next
        #else
        #  cache[key] = loss
        #end

        key = {c, dir}
        cached = cache[key][0..(streak-1)]
        next if cached.any? { |l| l <= loss }
        cache[key][streak-1] = loss

        item = { c, loss, dir, streak, cur[4] + [cur[0]] }
        queue << item
        #case dir
        #when Map::SOUTH, Map::EAST
        #  queue << item
        #when Map::NORTH, Map::WEST
        #  queue.unshift item
        #end
      end
    end

    best
  end

  def draw(map, q)
    debug q
    resolver = ->(c : Coord, t : Int32 | Nil) : Char | Nil {
      c.in?(q[4]) ? 'o' : '.'
    }
    map.draw resolver: resolver
    debug ""
    debug_line q[1]
  end

  def part2(lines)
  end
end
