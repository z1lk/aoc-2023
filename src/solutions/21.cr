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
    property? overflow : Bool = true

    def initialize(@coord, @blank, @containers, @created_at)
      @map = @blank.clone
      @map2 = @blank.clone
      @ring = Map.dist(@coord, {x: 0, y: 0})
      @containers << self
      @hist = [] of Int32
      @overflow = true
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
      c = Map.add(coord, Map::NORTH)
      up =
        if mc = containers.find { |mc| mc.coord == c }
          mc
        else
          MapContainer.new(c, blank.clone, containers, step)
        end
      raise "up not found" unless up
      up.down = self
      self.up = up
      up
    end
    def get_right(step)
      if right = self.right
        return right 
      end
      c = Map.add(coord, Map::EAST)
      right =
        if mc = containers.find { |mc| mc.coord == c }
          mc
        else
          MapContainer.new(c, blank.clone, containers, step)
        end
      raise "right not found" unless right
      right.left = self
      self.right = right
      right
    end
    def get_down(step)
      if down = self.down
        return down 
      end
      c = Map.add(coord, Map::SOUTH)
      down =
        if mc = containers.find { |mc| mc.coord == c }
          mc
        else
          MapContainer.new(c, blank.clone, containers, step)
        end
      raise "down not found" unless down
      down.up = self
      self.down = down
      down
    end
    def get_left(step)
      if left = self.left
        return left 
      end
      c = Map.add(coord, Map::WEST)
      left =
        if mc = containers.find { |mc| mc.coord == c }
          mc
        else
          MapContainer.new(c, blank.clone, containers, step)
        end
      raise "left not found" unless left
      left.right = self
      self.left = left
      left
    end

    def build(step)
      return if finished?
      map.find_all('O').each do |c|
        map.neighbors(c).each do |(d,t)|
          next if t == '#'
          if map.in_bounds?(d)
            map2.set(d, 'O')
          elsif overflow?
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
      if finished?
        hist << hist[-2]
      else
        self.map = map2
        hist << reachable.size
        self.map2 = blank.clone
      end
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

    tmp = MapContainer.new({x: 0, y: 0}, blank, containers, 0)
    tmp.map.set(start, 'O')
    tmp.overflow = false
    i = 1
    loop do
      tmp.build(i)
      tmp.step(i)
      if tmp.hist.size > 3 
        if tmp.hist[-1] == tmp.hist[-3] && tmp.hist[-2] == tmp.hist[-4]
          tmp.finished!(i) 
          break
        end
      end
      i += 1
    end
    puts tmp.hist
    tmp_hist = tmp.hist.dup
    max = tmp.hist.max
    tmp_hist.pop unless tmp_hist[-1] == max
    max_prev = tmp_hist[-2]
    raise "max and max_prev same" if max == max_prev

    #stop_step = 5000
    stop_step = 26501365

    even_ring_finish_count, odd_ring_finish_count =
      if (tmp.hist.index!(max) + 1).even? && stop_step.even?
        { max, max_prev }
      else
        { max_prev, max }
      end

    debug_line "even_ring_finish_count", even_ring_finish_count 
    debug_line "odd_ring_finish_count", odd_ring_finish_count 

    containers.clear

    cont = MapContainer.new({x: 0, y: 0}, blank, containers, 0)
    cont.map.set(start, 'O')

    #steps = 26501365
    #steps = 50
    #reachable = [1]
    ring_start = Hash(Int32, Int32).new
    ring_finish = Hash(Int32, Int32).new
    step = 0
    # steps.times do |step|
    loop do
      step = step + 1
      debug_line "step", step
      containers.each { |mc| mc.build(step) }# (&.build)
      containers.each { |mc| mc.step(step) }
      #if step.even? == steps.even?
        containers.each do |mc|
          next if mc.finished?
          next unless mc.hist.size > 3 # enough to repeat twice
          next unless mc.hist[-1] == mc.hist[-3] && mc.hist[-2] == mc.hist[-4] # started repeating
          if mc.ring.even? && mc.hist[-1] == even_ring_finish_count || mc.ring.odd? && mc.hist[-1] == odd_ring_finish_count
            mc.finished!(step)
          end
        end
      #end
      #reachable << containers.sum { |mc| mc.reachable.size }
      draw_containers(containers)
      stop_ring = 3
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

    last_ring_started = simulate_continuous ring_start, stop_step
    #last_ring_finished = simulate_continuous ring_finish, stop_step
    raise "no ring started" if last_ring_started.nil?
    # fake it?
    last_ring_finished = last_ring_started - 3
    raise "no ring finished" if last_ring_finished.nil?

    debug_line "stop_step", stop_step
    debug_line "last_ring_started", last_ring_started

    debug_line "last_ring_finished", last_ring_finished

    if last_ring_finished > last_ring_started
      raise "last_ring_finished (#{last_ring_finished}) > last_ring_started (#{last_ring_started})" 
    end

    outer_start = 0
    if last_ring_finished
      outer_start = last_ring_finished + 1
    end

    if outer_start > last_ring_started
      raise "outer_start (#{outer_start}) > last_ring_started (#{last_ring_started})" 
    end

    #raise "no ring started" if last_ring_started.nil?
    #raise "no ring finished" if last_ring_finished.nil?
    #same_finish_count = containers.find! { |mc| mc.coord == {x: 0, y: 0} }.reachable.size
    #other_finish_count = containers.find! { |mc| mc.coord == {x: -1, y: 0} }.reachable.size
    #debug_line "same_finish_count", same_finish_count
    #debug_line "other_finish_count", other_finish_count

    #center_finish_count, other_finish_count =
    #  if cont.hist.index!(max).even? && stop_step.even?
    #    { max, max_prev }
    #  else
    #    { max_prev, max }
    #  end

    inner = 0
    if last_ring_finished
      inner = 0_i128.to(last_ring_finished).sum do |r|
        count = r.even? ? even_ring_finish_count : odd_ring_finish_count #center_finish_count : other_finish_count
        size = ring_size(r)
        total = size.to_i128 * count
        #debug_line "ring", r, "size", size, "count", count, "total", total
        total
      end
    end

    #puts "***"
    #puts outer_start
    #puts last_ring_started
    #puts "***"

    outer_rings = outer_start.to(last_ring_started).to_a
    outers = outer_rings.map do |r|
      ring_start_step = get_step ring_start, r
      state = stop_step - ring_start_step
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
        next 0 if times < 1 # ring 0 
        offset_state = state - offset
        next 0 if offset_state < 0 # not started yet
        #debug "--------"
        #debug hist
        #debug offset_state
        #v = hist[offset_state] * times
        #debug v
        #v
        if hist[-1] == max
          100.times do
            hist << max_prev
            hist << max
          end
        end
        #debug "---"
        #debug_line "stop_step", stop_step
        #debug_line "ring_start_step", ring_start_step
        #debug_line "state", state
        #debug_line "hist", hist
        #debug_line "hist.size", hist.size
        #debug_line "offset", offset
        #debug_line "offset_state", offset_state
        #debug "---"
        #puts offset_state
        hist[offset_state].to_i128 * times
      end
    end
    outer_rings.each.with_index do |r, i|
      debug_line "outer_ring", r, "count", outers[i]
    end

    outer = outers.sum

    debug_line "inner", inner
    debug_line "outer", outer

    inner + outer

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
    debug_line "last_k", last_k
    debug_line "last_v", last_v
    if m < last_v
      hash.find! do |k,v|
        m >= v
      end[0]
    end
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
