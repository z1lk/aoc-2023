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

    property finished_at : Int32 | Nil
    property containers : Array(MapContainer)

    property hist : Array(Int32) = [] of Int32

    def initialize(@coord, @blank, @containers)
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

    def get_up
      if up = self.up
        return up
      end
      if m = left.try(&.up).try(&.right)
        self.up = m
      elsif m = right.try(&.up).try(&.left)
        self.up = m
      else
        c = Map.add(coord, Map::NORTH)
        self.up = MapContainer.new(c, blank.clone, containers)
      end
      up = self.up
      raise "up not found" unless up
      up.down = self
      up
    end
    def get_right
      if right = self.right
        return right
      end
      if m = up.try(&.right).try(&.down)
        self.right = m
      elsif m = down.try(&.right).try(&.up)
        self.right = m
      else
        c = Map.add(coord, Map::EAST)
        self.right = MapContainer.new(c, blank.clone, containers)
      end
      right = self.right
      raise "right not found" unless right
      right.left = self
      right
    end
    def get_down
      if down = self.down
        return down
      end
      if m = left.try(&.down).try(&.right)
        self.down = m
      elsif m = right.try(&.down).try(&.left)
        self.down = m
      else
        c = Map.add(coord, Map::SOUTH)
        self.down = MapContainer.new(c, blank.clone, containers)
      end
      down = self.down
      raise "down not found" unless down
      down.up = self
      down
    end
    def get_left
      if left = self.left
        return left
      end
      if m = down.try(&.left).try(&.up)
        self.left = m
      elsif m = up.try(&.left).try(&.down)
        self.left = m
      else
        c = Map.add(coord, Map::WEST)
        self.left = MapContainer.new(c, blank.clone, containers)
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
              left = get_left
              next if left.finished?
              e = {x: map.max_x, y: d[:y]}
              left.map2.set(e, 'O')
            elsif d[:x] > map.max_x
              right = get_right
              next if right.finished? #|| right.ring < ring
              e = {x: map.min_x, y: d[:y]}
              right.map2.set(e, 'O')
            elsif d[:y] < map.min_y
              up = get_up
              next if up.finished? #|| up.ring < ring
              e = {x: d[:x], y: map.max_y}
              up.map2.set(e, 'O')
            elsif d[:y] > map.max_y
              down = get_down
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

  def part2(lines)
    map = Parsers.map(lines)
    start = map.find!('S')
    blank = map.clone
    blank.set(start, '.')
    containers = [] of MapContainer
    max = blank.find_all('.').size
    cont = MapContainer.new({x: 0, y: 0}, blank, containers)
    cont.map.set(start, 'O')
    #steps = 26501365
    #steps = 50
    steps = 50
    reachable = [1]
    steps.times do |step|
      debug_line "step", step
      containers.each { |mc| mc.build(step) }# (&.build)
      containers.each { |mc| mc.step(step) }
      containers.each do |mc|
        next if mc.finished?
        mc.finished!(step) if mc.reachable.size == max
      end
      reachable << containers.sum { |mc| mc.reachable.size }
      #draw_containers(containers)
    end
  end

  def draw_containers(containers)
    coords = containers.map(&.coord)
    xa = coords.map { |c| c[:x] }
    ya = coords.map { |c| c[:x] }
    print " " * 7
    xa.min.to(xa.max) do |x|
      print x.to_s.rjust(4, ' ') + " "
    end
    puts ""
    ya.min.to(ya.max) do |x|
      print x.to_s.rjust(4, ' ') + " | "
      xa.min.to(xa.max) do |y|
        cont = containers.find { |mc| mc.coord == { x: x, y: y } }
        if cont
          print cont.reachable.size.to_s.rjust(4, ' ') + " "
        else
          print "----" + " "
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
