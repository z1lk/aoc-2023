class Aoc2023::TwentyOne < Aoc2023::Solution
  def part1(lines)
    map = Parsers.map(lines)
    start = map.find!('S')
    map.set(start, '.')
    plots = map.find_all('.')
    map.to_s

    steps = 64
    map.set(start,'O')
    steps.times do |step|
      # clone and reset the map
      map2 = map.clone
      map2.find_all('O').each do |c|
        map2.set(c, '.')
      end
      map.find_all('O').each do |c|
        map.neighbors(c).each do |(d,t)|
          next if t == '#'
          next unless map.in_bounds?(d)
          map2.set(d, 'O')
        end
      end
      map = map2
      #debug map.to_s
    end
    map.find_all('O').size
  end

  class MapContainer
    property coord : Coord
    property ring : Int32

    property map : Map(Char)
    property map2 : Map(Char)
    property blank : Map(Char)

    property up : MapContainer | Nil
    property right : MapContainer | Nil
    property down : MapContainer | Nil
    property left : MapContainer | Nil

    property created_at : Int32
    property finished_at : Int32 | Nil
    property containers : Array(MapContainer)

    property hist : Array(Int32) = [] of Int32

    def initialize(@coord, @blank, @containers, @created_at)
      @map = @blank.clone
      @map2 = @blank.clone
      @ring = Map.dist(@coord, {x: 0, y: 0})
      @containers << self
      @hist = [] of Int32
    end

    def finished?
      !finished_at.nil?
    end

    def finished!(step)
      self.finished_at = step
    end

    def new?
      map.find_all('O').size == 0
    end

    def get_up(step)
      if up = self.up
        return up
      end
      if m = left.try(&.up).try(&.right)
        self.up = m
      elsif m = right.try(&.up).try(&.left)
        self.up = m
      else
        c = Map.add(coord, Map::NORTH)
        self.up = MapContainer.new(c, blank.clone, containers, step)
      end
      up = self.up
      raise "up not found" unless up
      up.down = self
      up
    end
    def get_right(step)
      if right = self.right
        return right
      end
      if m = up.try(&.right).try(&.down)
        self.right = m
      elsif m = down.try(&.right).try(&.up)
        self.right = m
      else
        c = Map.add(coord, Map::EAST)
        self.right = MapContainer.new(c, blank.clone, containers, step)
      end
      right = self.right
      raise "right not found" unless right
      right.left = self
      right
    end
    def get_down(step)
      if down = self.down
        return down
      end
      if m = left.try(&.down).try(&.right)
        self.down = m
      elsif m = right.try(&.down).try(&.left)
        self.down = m
      else
        c = Map.add(coord, Map::SOUTH)
        self.down = MapContainer.new(c, blank.clone, containers, step)
      end
      down = self.down
      raise "down not found" unless down
      down.up = self
      down
    end
    def get_left(step)
      if left = self.left
        return left
      end
      if m = down.try(&.left).try(&.up)
        self.left = m
      elsif m = up.try(&.left).try(&.down)
        self.left = m
      else
        c = Map.add(coord, Map::WEST)
        self.left = MapContainer.new(c, blank.clone, containers, step)
      end
      left = self.left
      raise "left not found" unless left
      left.right = self
      left
    end

    def build(step)
      return if finished?
      map.find_all('O').each do |c|
        map.neighbors(c).each do |(d,t)|
          next if t == '#'
          if map.in_bounds?(d)
            map2.set(d, 'O')
          else
            if d[:x] < map.min_x
              left = get_left(step)
              next if left.finished?
              e = {x: map.max_x, y: d[:y]}
              left.map2.set(e, 'O')
            elsif d[:x] > map.max_x
              right = get_right(step)
              next if right.finished? #|| right.ring < ring
              e = {x: map.min_x, y: d[:y]}
              right.map2.set(e, 'O')
            elsif d[:y] < map.min_y
              up = get_up(step)
              next if up.finished? #|| up.ring < ring
              e = {x: d[:x], y: map.max_y}
              up.map2.set(e, 'O')
            elsif d[:y] > map.max_y
              down = get_down(step)
              next if down.finished? #|| down.ring < ring
              e = {x: d[:x], y: map.min_y}
              down.map2.set(e, 'O')
            end
          end
        end # neighbors.each
      end # all O
    end

    def step(n)
      return if finished?
      self.map = map2
      hist << reachable.size
      self.map2 = blank.clone
    end

    def reachable2
      map2.find_all('O')
    end

    def reachable
      map.find_all('O')
    end
  end

  def ring_size(r)
    return 1 if r == 0
    4 * r
  end

  #def reachable(coord)

  def part2(lines)
    map = Parsers.map(lines)
    start = map.find!('S')
    blank = map.clone
    blank.set(start, '.')
    containers = [] of MapContainer
    cont = MapContainer.new({x: 0, y: 0}, blank, containers, 0)
    cont.map.set(start, 'O')
    steps = 26501365
    #steps = 50
    #reachable = [1]
    ring_start = Hash(Int32, Int32).new
    ring_finish = Hash(Int32, Int32).new
    steps.times do |step|
      step = step + 1
      debug_line "step", step
      containers.each { |mc| mc.build(step) }# (&.build)
      containers.each { |mc| mc.step(step) }
      if step.even? == steps.even?
        containers.each do |mc|
          next if mc.finished?
          next unless mc.hist.size > 3
          mc.finished!(step) if mc.hist[-1] == mc.hist[-3] && mc.hist[-2] == mc.hist[-4]
        end
      end
      #reachable << containers.sum { |mc| mc.reachable.size }
      draw_containers(containers)
      stop_ring = 5
      ring_mc = containers.select { |mc| mc.ring == stop_ring }
      if ring_size(stop_ring) == ring_mc.size && ring_mc.all?(&.finished?)
        break
      end
      max_ring = containers.map { |mc| mc.ring }.max
      0.to(max_ring).each do |ring|
        if !ring_start.has_key?(ring)
          ring_start[ring] = step
        end
        if !ring_finish.has_key?(ring)
          ring_mc = containers.select { |mc| mc.ring == ring }
          if ring_size(ring) == ring_mc.size && ring_mc.all?(&.finished?)
            ring_finish[ring] = step
          end
        end
      end
      #rings_unfinished = 1.to(max_ring).to_a.select do |r| 
      #  r_mc = containers.select { |mc| mc.ring == r }
      #  !r_mc.all?(&.finished?)
      #end
      #if rings_unfinished.size > 3
      #  raise "rings_unfinished: #{rings_unfinished}"
      #end
    end

    debug_line "ring_start", ring_start
    debug_line "ring_finish", ring_finish

    #debug get_step ring_start, 7
    #debug get_step ring_start, 8
    #debug get_step ring_start, 9

    # all from ring 3
    t =  containers.find! { |mc| mc.coord == { x:  0, y: -3} }
    b =  containers.find! { |mc| mc.coord == { x:  0, y:  3} }
    l =  containers.find! { |mc| mc.coord == { x: -3, y:  0} }
    r =  containers.find! { |mc| mc.coord == { x:  3, y:  0} }
    tl = containers.find! { |mc| mc.coord == { x: -1, y: -2} }
    tr = containers.find! { |mc| mc.coord == { x:  1, y: -2} }
    bl = containers.find! { |mc| mc.coord == { x: -1, y:  2} }
    br = containers.find! { |mc| mc.coord == { x:  1, y:  2} }

    t_hist =  t.hist
    b_hist =  b.hist
    l_hist =  l.hist
    r_hist =  r.hist
    tl_hist = tl.hist
    tr_hist = tr.hist
    bl_hist = bl.hist
    br_hist = br.hist

    ring3_start = ring_start[3]
    t_offset = t.created_at - ring3_start
    b_offset = b.created_at - ring3_start
    l_offset = l.created_at - ring3_start
    r_offset = r.created_at - ring3_start
    tl_offset = tl.created_at - ring3_start
    tr_offset = tr.created_at - ring3_start
    bl_offset = bl.created_at - ring3_start
    br_offset = br.created_at - ring3_start

    #debug_line "t_offset", t_offset
    #debug_line "b_offset", b_offset
    #debug_line "l_offset", l_offset
    #debug_line "r_offset", r_offset
    #debug_line "tl_offset", tl_offset
    #debug_line "tr_offset", tr_offset
    #debug_line "bl_offset", bl_offset
    #debug_line "br_offset", br_offset

    n = 5000
    ring_started = simulate_continuous ring_start, n
    ring_finished = simulate_continuous ring_finish, n

    #raise "no ring started" if ring_started.nil?
    #raise "no ring finished" if ring_finished.nil?

    debug_line "step", n
    debug_line "ring started", ring_started
    debug_line "ring finished", ring_finished
    same_finish_count = containers.find! { |mc| mc.coord == {x: 0, y: 0} }.reachable.size
    other_finish_count = containers.find! { |mc| mc.coord == {x: -1, y: 0} }.reachable.size
    debug_line "same_finish_count", same_finish_count
    debug_line "other_finish_count", other_finish_count
    
    inner = 0
    if ring_finished
      0_i128.to(ring_finished).sum do |r|
        count = r.even? ? same_finish_count : other_finish_count
        ring_size(r).to_i128 * count
      end
    end

    outer_start = 0
    if ring_finished
      outer_start = (ring_finished + 1)
    end

    raise "no ring started" if ring_started.nil?

    puts "***"
    puts outer_start
    puts ring_started
    puts "***"

    outer = outer_start.to(ring_started).sum do |r|
      ring_start_step = get_step ring_start, r
      state = n - ring_start_step
      #debug_line "ring_start_step", ring_start_step
      #debug_line "state", state
      [
        {t_hist, t_offset, 1},
        {b_hist, b_offset, 1},
        {l_hist, l_offset, 1},
        {r_hist, r_offset, 1},
        {tl_hist, tl_offset, r-1},
        {tr_hist, tr_offset, r-1},
        {bl_hist, bl_offset, r-1},
        {br_hist, br_offset, r-1}
      ].sum do |(hist, offset, times)|
        offset_state = state - offset
        next 0 if times < 1 # ring 0 
        next 0 if offset_state < 0
        #debug "--------"
        #debug hist
        #debug offset_state
        #v = hist[offset_state] * times
        #debug v
        #v
        #debug "---"
        #debug_line "hist", hist.size
        #debug_line "state", state
        #debug_line "offset", offset
        #debug_line "offset_state", offset_state
        #debug "---"
        hist[offset_state] * times
      end
    end

    debug_line "inner", inner
    debug_line "outer", outer

    debug inner + outer

    #debug "---"
    #debug simulate_continuous ring_start, 65
    #debug simulate_continuous ring_start, 66
    #debug simulate_continuous ring_start, 67
    #debug "---"
    #debug simulate_continuous ring_start, 76
    #debug simulate_continuous ring_start, 77
    #debug simulate_continuous ring_start, 78
    #debug "---"
    #debug simulate_continuous ring_finish, 41
    #debug simulate_continuous ring_finish, 42
    #debug simulate_continuous ring_finish, 43
    #debug simulate_continuous ring_finish, 44

    #debug containers.find! { |mc| mc.coord == { x: 1, y: 2 } }.hist
    #debug containers.find! { |mc| mc.coord == { x: 2, y: 1 } }.hist
    #debug containers.find! { |mc| mc.coord == { x: 1, y: 3 } }.hist
    #debug containers.find! { |mc| mc.coord == { x: 2, y: 2 } }.hist
    #debug containers.find! { |mc| mc.coord == { x: 3, y: 1 } }.hist
  end

  def get_step(hash : Hash(Int32, Int32), m)
    return hash[m] if hash.has_key?(m)
    v_diff = hash.values[-1] - hash.values[-2]
    last_k = hash.keys[-1]
    last_v = hash.values[-1]
    last_v + (m - last_k) * v_diff
  end

  def simulate_continuous(hash : Hash(Int32, Int32), m)
    v_diff = hash.values[-1] - hash.values[-2]
    last_k = hash.keys[-1]
    last_v = hash.values[-1]
    return nil if m < hash.values[0]
    if m < last_v
      hash.find! do |k,v|
        m >= v
      end[0]
    end
    puts "HERE"
    r = (m - last_v) // v_diff
    r + last_k
  end

  def draw_containers(containers)
    puts ""
    coords = containers.map(&.coord)
    xa = coords.map { |c| c[:x] }
    ya = coords.map { |c| c[:x] }
    print " " * 5 + "| "
    xa.min.to(xa.max) do |x|
      print x.to_s.rjust(4, ' ') + " "
    end
    puts ""
    print "-" * 5 + "+-"
    xa.min.to(xa.max) do |x|
      print "-" * 5 + "-"
    end
    puts ""
    ya.min.to(ya.max) do |x|
      print x.to_s.rjust(4, ' ') + " | "
      xa.min.to(xa.max) do |y|
        cont = containers.find { |mc| mc.coord == { x: x, y: y } }
        if cont
          print cont.reachable.size.to_s.rjust(4, ' ') + " "
        else
          print "    " + " "
        end
      end
      puts ""
    end
  end

  def part2_b(lines)
    map = Parsers.map(lines)
    start = map.find!('S')
    blank = map.clone
    blank.set(start, '.')
    width = blank.max_x + 1
    height = blank.max_y + 1

    scale = 5
    lines_b = blank.to_s.lines.map { |l| l * scale } * scale
    map_b = Parsers.map(lines_b)
    start_b = { x: (width * scale) // 2, y: (height * scale) // 2 }
    #map_b.set(start2, 'S')

    reachable = [1]# of Int32
    #steps = 50
    steps = 30
    map_b.set start_b, 'O'
    steps.times do |step|
      sleep 1
      debug map_b.to_s
      # clone and reset the map
      map2 = map_b.clone
      map2.find_all('O').each do |c|
        map2.set(c, '.')
      end
      map_b.find_all('O').each do |c|
        map_b.neighbors(c).each do |(d,t)|
          next if t == '#'
          next unless map_b.in_bounds?(d)
          map2.set(d, 'O')
        end
      end
      map_b = map2
      #debug map.to_s
      reachable << map_b.find_all('O').size
    end
    #  (b - a).to_s.rjust(2)
    #end.join(','))
    reachable.each.with_index do |r,i|
      debug_line r, i
    end
    #map_b.find_all('O').size
  end

end
