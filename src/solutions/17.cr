class Aoc2023::Seventeen < Aoc2023::Solution
  def parse(lines)
    map = Array(Array(Int32)).new
    lines.map do |line|
      map << line.chars.map(&.to_i32)
    end
    Map.new(map)
  end

  # best-first search with aggressive caching and pruning
  # with dumb reassessment of priority of all nodes every step
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

    # cache coord, dir = array(streak, loss)
    cache = Hash(Tuple(Coord, Coord), Array(Int32)).new
    map.each do |c,t|
      Map::ADJ.each do |dir|
        cache[{c,dir}] = [Map::UNREACHABLE, Map::UNREACHABLE, Map::UNREACHABLE]
      end
    end

    i = 0_i128
    until queue.empty?
      cur = queue.min_by { |q| [dist_precomp[q[0]], q[1]] }
      queue.delete cur

      if cur[0] == stop
        if cur[1] < best
          best = cur[1] 
          queue.reject! do |q|
            next true if q[1] >= best
            loss_left = best - q[1]
            next true if dist_precomp[q[0]] > loss_left
          end
        end
        next
      end

      # opp is the direction opposite the current direction which we can't travel in
      opp = case cur[2]
            when Map::NORTH then Map::SOUTH
            when Map::EAST then Map::WEST
            when Map::SOUTH then Map::NORTH
            when Map::WEST then Map::EAST
            end
      neighbors = Map::ADJ.-([opp]).map do |dir|
        n = map.add(cur[0],dir)
        { n, map.get(n), dir }
      end
      neighbors.each do |(c,t,dir)|
        next if c.in?(cur[4]) # neighbor is in path
        next if t.nil? # outside map
        loss = cur[1] + t
        next unless loss < best
        streak = dir == cur[2] ? cur[3] + 1 : 1
        next if streak > 3
        key = {c, dir}
        cached = cache[key][0..(streak-1)]
        next if cached.any? { |l| l <= loss }
        cache[key][streak-1] = loss
        item = { c, loss, dir, streak, cur[4] + [cur[0]] }
        queue << item
      end
    end

    best
  end

  def part2(lines)
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
    # streak=4 is to satisfy that condition in the case of the starting square...
    # we can go in either direction even though we have no previous streak >= 4
    queue << { start, 0, {x: 0, y: 0}, 4, [] of Coord }
    best = Map::UNREACHABLE
    # cache coord, dir = array(streak, loss)
    cache = Hash(Tuple(Coord, Coord), Array(Int32)).new
    map.each do |c,t|
      Map::ADJ.each do |dir|
        cache[{c,dir}] = [Map::UNREACHABLE] * 10
      end
    end

    i = 0_i128
    until queue.empty?
      cur = queue.min_by { |q| [dist_precomp[q[0]], q[1]] }
      queue.delete cur

      if cur[0] == stop
        next unless cur[3] >= 4
        if cur[1] < best
          best = cur[1] 
          queue.reject! do |q|
            next true if q[1] >= best
            loss_left = best - q[1]
            next true if dist_precomp[q[0]] > loss_left
          end
        end
        next
      end

      opp = case cur[2]
            when Map::NORTH then Map::SOUTH
            when Map::EAST then Map::WEST
            when Map::SOUTH then Map::NORTH
            when Map::WEST then Map::EAST
            end
      neighbors = Map::ADJ.-([opp]).map do |dir|
        n = map.add(cur[0],dir)
        { n, map.get(n), dir }
      end
      neighbors.each do |(c,t,dir)|
        next if c.in?(cur[4]) # neighbor is in path
        next if t.nil? # outside map
        loss = cur[1] + t
        next unless loss < best
        streak = dir == cur[2] ? cur[3] + 1 : 1
        next if streak > 10
        # must go at least 4 before can go in other direction
        next if cur[2] != dir && cur[3] < 4
        key = {c, dir}
        # if streak is less than 4, we have restriction on movement,
        # only compare loss to cached value of exact streak
        if streak < 4
          next if cache[key][streak-1] <= loss
        else
          # no restriction on movement,
          # loss can be compared to all cached value with unrestricted movement
          cached = cache[key][(4-1)..(streak-1)]
          next if cached.any? { |l| l <= loss }
        end
        cache[key][streak-1] = loss
        item = { c, loss, dir, streak, cur[4] + [cur[0]] }
        queue << item
      end
    end

    best
  end

  #def draw(map, q)
  #  debug q
  #  resolver = ->(c : Coord, t : Int32 | Nil) : Char | Nil {
  #    c.in?(q[4]) ? 'o' : '.'
  #  }
  #  map.draw resolver: resolver
  #end
end
