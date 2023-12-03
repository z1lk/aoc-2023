module Aoc2023
  alias Coords = NamedTuple(x: Int32, y: Int32)

  UNREACHABLE = Int32::MAX

  class Map(T)
    def_clone

    property map : Hash(Int32, Hash(Int32, Array(T)))

    getter min_y : Int32, max_y : Int32, min_x : Int32, max_x : Int32

    def initialize()
      @map = Hash(Int32, Hash(Int32, Array(T))).new
      @min_y = 0
      @max_y = 0
      @min_x = 0
      @max_x = 0
    end

    def initialize(map : Array(Array(T)))
      @map = Hash(Int32, Hash(Int32, Array(T))).new
      map.each.with_index do |row, y|
        @map[y] = Hash(Int32, Array(T)).new
        row.each.with_index do |tile, x|
          @map[y][x] = [tile]
        end
      end
      y_a = @map.keys
      x_a = @map.values.map(&.keys).flatten.uniq
      @min_y = y_a.min
      @max_y = y_a.max
      @min_x = x_a.min
      @max_x = x_a.max
    end

    def initialize(map : Array(Array(Array(T))))
      @map = Hash(Int32, Hash(Int32, Array(T))).new
      map.each.with_index do |row, y|
        @map[y] = Hash(Int32, Array(T)).new
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

    def extend_bounds(coord)
      #y_a = @map.keys
      #x_a = @map.values.map(&.keys).flatten.uniq
      y_a = [coord[:y], min_y, max_y]
      x_a = [coord[:x], min_x, max_x]
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
      each do |coord, tiles|
        min_y = coord[:y] if min_y == UNREACHABLE
        max_y = coord[:y] if max_y == UNREACHABLE
        min_x = coord[:x] if min_x == UNREACHABLE
        max_x = coord[:x] if max_x == UNREACHABLE
        min_y = coord[:y] if min_y > coord[:y]
        max_y = coord[:y] if max_y < coord[:y]
        min_x = coord[:x] if min_x > coord[:x]
        max_x = coord[:x] if max_x < coord[:x]
      end
      @min_y = min_y
      @max_y = max_y
      @min_x = min_x
      @max_x = max_x
    end

    def get(coord : Coords, default : T | Nil = nil)
      if (row = map[coord[:y]]?)
        if (val = row[coord[:x]]?)
          return val
        end
      end
      if default.nil?
        [] of T
      else
        [default]
      end
    end

    def set(coord : Coords, val : T)
      map[coord[:y]] ||= Hash(Int32, Array(T)).new
      map[coord[:y]][coord[:x]] ||= Array(T).new
      map[coord[:y]][coord[:x]] << val
      extend_bounds(coord)
    end

    def unset(coord : Coords, val : T, prune = true)
      x, y = coord[:x], coord[:y]
      return if map[y]?.nil?
      return if map[y][x]?.nil?
      map[y][x].delete val
      map[y].delete(x) if map[y][x].empty? if prune
      map.delete(y) if map[y].empty? if prune
      true
    end

    def find(tile : T)
      each do |coord, tiles|
        return coord if tiles.includes?(tile)
      end
    end

    def find_all(tile : T)
      coords = [] of Coords
      each do |coord, tiles|
        coords << coord if tiles.includes?(tile)
      end
      coords
    end

    def all_y; map.keys; end
    def all_x; map.values.flatten.map(&.keys).flatten.uniq; end

    def each(default : T | Nil = nil)
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          coord = {x: x, y: y}
          yield coord, get(coord, default)
        end
      end
    end

    def add(coord : Coords, coord2 : Coords)
      {
        x: coord[:x] + coord2[:x],
        y: coord[:y] + coord2[:y]
      }
    end

    def diff(coord : Coords, coord2 : Coords)
      {
        x: coord[:x] - coord2[:x],
        y: coord[:y] - coord2[:y]
      }
    end

    def diagonal?(coord : Coords, coord2 : Coords)
      [
        {x: -1, y: -1},
        {x: -1, y: 1},
        {x: 1, y: -1},
        {x: 1, y: 1}
      ].includes?(diff(coord,coord2))
    end

    def neighbors(coord : Coords, diagonal = false, center = false)
      neighboring_tiles = [
        {x: 0, y: -1},
        {x: 0, y: 1},
        {x: -1, y: 0},
        {x: 1, y: 0}
      ]
      if diagonal
        neighboring_tiles.concat([
          {x: -1, y: -1},
          {x: -1, y: 1},
          {x: 1, y: -1},
          {x: 1, y: 1}
        ])
      end
      if center
        neighboring_tiles.concat([
          {x: 0, y: 0},
        ])
      end
      neighboring_tiles.map do |d|
        add(coord, d)
      end.compact
    end

    # taxicab dist
    def dist(a, b)
      (a[:x] - b[:x]).abs + (a[:y] - b[:y]).abs
    end

    def draw(
      min_width = 9,
      width : Int32 | Nil = nil,
      height : Int32 | Nil = nil,
      center : Coords | Nil = nil,
      x_offset : Int32 = 0,
      y_offset : Int32 = 0,
      clear = true,
      interval = 0.1,
      outside_bounds = false
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
          tiles = get({x: x, y: y})
          char = yield(tiles, {x: x, y: y})
          debug_buffered char, print: true
        end
      end

      sleep interval if interval
      system("clear") if clear
      debug_flush
    end
  end
end
