class Aoc2023::Ten < Aoc2023::Solution
  # pipes
  VER = '|'
  HOR = '-'
  NE = 'L'
  NW = 'J'
  SW = '7'
  SE = 'F'

  PIPE = [VER, HOR, NE, NW, SW, SE]

  NONE = '.'
  START = 'S'
  BOUND = 'X'
  OUT = 'O'
  IN = 'I'

  def part1(lines)
    map = Parsers.map(lines)
    find_circ(map).size.-(1) // 2
  end

  def part2(lines)
    map = Parsers.map(lines)
    circ = find_circ(map)
    # get rid of all the random bits of pipe
    map.each do |c, t|
      next if c.in?(circ)
      map.set(c, NONE)
    end
    # extend the bounds by 1 and fill with 'O' to make algo smoother
    map.extend_bounds({x: map.min_x - 1, y: map.min_y - 1})
    map.extend_bounds({x: map.max_x + 1, y: map.max_y + 1})
    map.fill(OUT)

    # iterate from top to bottom, left to right, tracking out/in and marking it on the map
    outside = true
    hor = false
    last_corner = nil
    map.min_y.upto(map.max_y).each do |y|
      map.min_x.upto(map.max_x).each do |x|
        coord = {x: x, y: y}
        c = map.get!(coord)
        case c
        when OUT
          outside = true
        when IN
          outside = false
        when VER
          outside = !outside
        when NE, NW, SW, SE
          # we're starting or finishing a horizontal section.
          # this may or may not reverse `outside`, depending on if
          # the pipe continues in the same direction or turns around.
          # if it continues, this is essentially a vertical section.
          # if it turns around, it has closed the loop it opened.
          if hor
            outside = 
              if pipe_ver_dir(c) == pipe_ver_dir(last_corner)
                outside
              else
                !outside
              end
            hor = false
            last_corner = nil
          else
            last_corner = c
            hor = true
          end
        when HOR
          hor = true
        when NONE
          map.set(coord, outside ? OUT : IN)
        end
      end
    end

    map.find_all(IN).size
  end

  def pipe_ver_dir(pipe)
    case pipe
    when NE then 'N'
    when NW then 'N'
    when SW then 'S'
    when SE then 'S'
    else
      raise "unrecognized pipe #{pipe}"
    end
  end

  def find_circ(map)
    start = map.find(START)
    raise "start not found" if start.nil?

    # we don't know what kind of pipe the 'S' is on.
    # attempt to go in each dir.
    # then we can figure out what pipe is underneath.
    # fake a vertical/horizontal pipe otherwise the can_go? checks will necessarily fail.
    map.set(start, VER)
    cg_n = can_go_n?(map, start)
    cg_s = can_go_s?(map, start)
    map.set(start, HOR)
    cg_e = can_go_e?(map, start)
    cg_w = can_go_w?(map, start)

    start_pipe =
      case
      when cg_n && cg_s then VER
      when cg_e && cg_w then HOR
      when cg_n && cg_e then NE
      when cg_n && cg_w then NW
      when cg_s && cg_e then SE
      when cg_s && cg_w then SW
      end
    raise "start pipe not identified" if start_pipe.nil?
    map.set(start, start_pipe)

    coords = [start]
    dir = {x: 0, y: 0}
    pos = start
    until pos == start && coords.size > 1
      dir = get_dir(map, pos, dir)
      pos = map.add(pos, dir)
      coords << pos
    end

    coords
  end

  # find out which way a section of pipe is leading.
  # last_dir is the previous direction, reversed to
  # find the dir we're coming from.
  def get_dir(map, coord, last_dir)
    from_dir = {
      Map::NORTH => Map::SOUTH,
      Map::SOUTH=> Map::NORTH,
      Map::EAST => Map::WEST,
      Map::WEST => Map::EAST
    }.fetch(last_dir, nil)
    case
    when from_dir != Map::NORTH && can_go_n?(map, coord)
      Map::NORTH
    when from_dir != Map::EAST && can_go_e?(map, coord)
      Map::EAST
    when from_dir != Map::SOUTH && can_go_s?(map, coord)
      Map::SOUTH
    when from_dir != Map::WEST && can_go_w?(map, coord)
      Map::WEST
    else
      raise "couldn't find good dir"
    end
  end

  def can_go_n?(map, coord)
    can_go?(map, coord, Map::NORTH, [VER, NW, NE], [VER, SW, SE])
  end

  def can_go_e?(map, coord)
    can_go?(map, coord, Map::EAST, [HOR, NE, SE], [HOR, NW, SW])
  end

  def can_go_s?(map, coord)
    can_go?(map, coord, Map::SOUTH, [VER, SW, SE], [VER, NW, NE])
  end

  def can_go_w?(map, coord)
    can_go?(map, coord, Map::WEST, [HOR, NW, SW], [HOR, NE, SE])
  end

  # there are unconnected bits of pipe about, so going in a certain
  # direction requires that the current section is of one kind ("outs"),
  # and the next section is of another kind ("ins").
  def can_go?(map, coord, dir, outs, ins)
    t = map.get(coord)
    return false if t.nil? || t == '?'
    return false if !t.in?(outs)
    t2 = map.get(map.add(coord, dir))
    return false if t2.nil? || t2 == '?'
    t2.in?(ins)
  end
end
