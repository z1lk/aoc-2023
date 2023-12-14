module Aoc2023
  alias Coord = NamedTuple(x: Int32, y: Int32)

  UNREACHABLE = Int32::MAX

  class Map(T)
    def_clone

    NORTH = {x: +0, y: -1}
    EAST  = {x: +1, y: +0}
    SOUTH = {x: +0, y: +1}
    WEST  = {x: -1, y: +0}

    property map : Hash(Int32, Hash(Int32, T | Nil))

    getter min_y : Int32, max_y : Int32, min_x : Int32, max_x : Int32

    def initialize()
      @map = Hash(Int32, Hash(Int32, T | Nil)).new
      @min_y = 0
      @max_y = 0
      @min_x = 0
      @max_x = 0
    end

    def initialize(map : Array(Array(T)))
      @map = Hash(Int32, Hash(Int32, T | Nil)).new
      map.each.with_index do |row, y|
        @map[y] = Hash(Int32, T | Nil).new
        row.each.with_index do |tile, x|
          @map[y][x] = tile
        end
      end
      y_a = @map.keys
      x_a = @map.values.map(&.keys).flatten.uniq
      @min_y = y_a.min
      @max_y = y_a.max
      @min_x = x_a.min
      @max_x = x_a.max
    end

    def ==(other : Map)
      @map == other.map
    end

    def extend_bounds(c)
      #y_a = @map.keys
      #x_a = @map.values.map(&.keys).flatten.uniq
      y_a = [c[:y], min_y, max_y]
      x_a = [c[:x], min_x, max_x]
      @min_y = y_a.min
      @max_y = y_a.max
      @min_x = x_a.min
      @max_x = x_a.max
    end

    def reset_bounds
      min_y = UNREACHABLE
      max_y = UNREACHABLE
      min_x = UNREACHABLE
      max_x = UNREACHABLE
      each do |c, t|
        next if t.nil?
        min_y = c[:y] if min_y == UNREACHABLE
        max_y = c[:y] if max_y == UNREACHABLE
        min_x = c[:x] if min_x == UNREACHABLE
        max_x = c[:x] if max_x == UNREACHABLE
        min_y = c[:y] if min_y > c[:y]
        max_y = c[:y] if max_y < c[:y]
        min_x = c[:x] if min_x > c[:x]
        max_x = c[:x] if max_x < c[:x]
      end
      @min_y = min_y
      @max_y = max_y
      @min_x = min_x
      @max_x = max_x
    end

    def rows(range)
      range.each.map do |r|
        min_x.to(max_x).map do |x|
          get({x: x, y: r})
        end.to_a
      end.to_a
    end

    def cols(range)
      range.each.map do |r|
        min_y.to(max_y).map do |y|
          get({x: r, y: y})
        end.to_a
      end.to_a
    end

    def get!(coord : Coord)
      t = get(coord)
      raise "no #{T} at #{coord}" if t.nil?
      t
    end

    def get(coord : Coord, default : T | Nil = nil)
      if (row = map[coord[:y]]?)
        if (t = row[coord[:x]]?)
          return t
        end
      end
      default
    end

    def in_bounds?(coord : Coord)
      x, y = coord[:x], coord[:y]
      x >= min_x && x <= max_x && y >= min_y && y <= max_y
    end

    def set(coord : Coord, val : T | Nil)
      x, y = coord[:x], coord[:y]
      map[y] ||= Hash(Int32, T | Nil).new
      map[y][x] = val
      extend_bounds(coord)
    end

    def swap(c : Coord, c2 : Coord)
      t = get c
      t2 = get c2
      unset c, t
      unset c2, t2
      set c, t2
      set c2, t
    end

    def unset(coord : Coord, prune = true)
      x, y = coord[:x], coord[:y]
      return if map[y]?.nil?
      return if map[y][x]?.nil?
      set(coord, nil)
      if prune
        map[y].delete(x)
        map.delete(y) if map[y].empty?
      end
      true
    end

    def fill(tile : T)
      each do |c, t|
        set(c, tile) if t.nil?
      end
    end

    def flood(c, t2, diagonal = false)
      set(c, t2)
      neighbors(c, diagonal).each do |nc, nt|
        next unless in_bounds?(nc)
        flood(nc, t2) if nt.nil?
      end
    end

    def find(tile : T)
      each do |c, t|
        return c if tile == t
      end
    end

    def find_all(tile : T)
      coords = [] of Coord
      each do |c, t|
        coords << c if tile == t
      end
      coords
    end

    #def all_y; map.keys; end
    #def all_x; map.values.flatten.map(&.keys).flatten.uniq; end
    #def all_y; min_x.upto(max_x).to_a; end
    #def all_x; min_y.upto(max_y).to_a; end

    def each(default : T | Nil = nil)
      min_y.to(max_y) do |y|
        min_x.to(max_x) do |x|
          c = {x: x, y: y}
          yield c, get(c, default)
        end
      end
    end

    def each(default : T | Nil = nil)
      min_y.to(max_y) do |y|
        min_x.to(max_x) do |x|
          c = {x: x, y: y}
          yield c, get(c, default)
        end
      end
    end
    def add(a : Coord, b : Coord)
      { x: a[:x] + b[:x], y: a[:y] + b[:y] }
    end

    def diff(a : Coord, b : Coord)
      { x: a[:x] - b[:x], y: a[:y] - b[:y] }
    end

    ADJ = [
      {x: 0, y: -1},
      {x: 0, y: 1},
      {x: -1, y: 0},
      {x: 1, y: 0}
    ]
    DIAG = [
      {x: -1, y: -1},
      {x: -1, y: 1},
      {x: 1, y: -1},
      {x: 1, y: 1}
    ]

    def adjacent?(a : Coord, b : Coord)
      ADJ.includes?(diff(a,b))
    end

    def diagonal?(a : Coord, b : Coord)
      DIAG.includes?(diff(a,b))
    end

    def neighbors(c : Coord, diagonal = false)
      diffs = ADJ.dup
      diffs.concat(DIAG.dup) if diagonal
      # diffs.concat([ {x: 0, y: 0} ]) if center
      diffs.map do |d|
        n = add(c, d)
        {n, get(n)}
      end
    end

    # taxicab dist
    def dist(a, b)
      (a[:x] - b[:x]).abs + (a[:y] - b[:y]).abs
    end

    def draw(
      min_width = 9,
      width : Int32 | Nil = nil,
      height : Int32 | Nil = nil,
      center : Coord | Nil = nil,
      x_offset : Int32 = 0,
      y_offset : Int32 = 0,
      clear = true,
      interval = 0.1,
      outside_bounds = false,
      resolver : Proc(Array(T), Coord, T) | Nil = nil
    )

      if width && height
        center ||= {
          x: (max_x + min_x)./(2).to_i32,
          y: (max_y + min_y)./(2).to_i32
        }

        if x_offset != 0 || y_offset != 0
          center = {
            x: center[:x] + x_offset,
            y: center[:y] + y_offset
          }
        end

        half_height = (height.to_f / 2).floor.to_i
        tmp_min_y = center[:y] - half_height
        tmp_max_y = center[:y] + half_height
        half_width = (width.to_f / 2).floor.to_i
        tmp_min_x = center[:x] - half_width
        tmp_max_x = center[:x] + half_width
      else
        tmp_min_y = min_y
        tmp_max_y = max_y
        tmp_min_x = min_x
        tmp_max_x = max_x

        until tmp_max_y - tmp_min_y >= 9
          tmp_max_y += 1
          tmp_min_y -= 1
        end
        until tmp_max_x - tmp_min_x >= 9
          tmp_max_x += 1
          tmp_min_x -= 1
        end
      end

      (tmp_min_y..tmp_max_y).each do |y|
        debug_buffered ""
        (tmp_min_x..tmp_max_x).each do |x|
          if !outside_bounds
            next if x < min_x
            next if x > max_x
            next if y < min_y
            next if y > max_y
          end
          t = get({x: x, y: y})
          t =
            if !resolver.nil?
              resolver.call(t, {x: x, y: y})
            else t
              t ? t : '?'
            end
          debug_buffered t, print: true
        end
      end

      sleep interval if interval
      system("clear") if clear
      debug_flush
    end

    def to_s
      min_y.to(max_y).map do |y|
        min_x.to(max_x).map do |x|
          get({x: x, y: y}, '?').to_s
        end.join
      end.join("\n")
    end
  end
end
