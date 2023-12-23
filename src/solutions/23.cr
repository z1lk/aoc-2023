class Aoc2023::TwentyThree < Aoc2023::Solution
  def part1(lines)
    map = Parsers.map(lines)
    start = { x: 1, y: 0 }
    stop = { x: map.max_x - 1, y: map.max_y }
    paths = [ [start] ] #of Array(Coord)
    lens = [] of Int32
    until paths.empty?
      path = paths.shift
      c = path[-1]
      t = map.get c
      map.neighbors(path[-1]).each do |nc, nt|
        next unless map.in_bounds?(nc)
        if nc == stop
          lens << path.size
          break
        end
        next if nt == '#'
        next if path.size > 1 && nc == path[-2]
        next if nc.in?(path)
        case t
        when '.'
          paths << (path.dup + [nc])
        when '^'
          paths << (path.dup + [nc]) if map.diff(nc, c) == Map::NORTH
        when '>'
          paths << (path.dup + [nc]) if map.diff(nc, c) == Map::EAST
        when 'v'
          paths << (path.dup + [nc]) if map.diff(nc, c) == Map::SOUTH
        when '<'
          paths << (path.dup + [nc]) if map.diff(nc, c) == Map::WEST
        else raise "unrecognized tile #{nt}"
        end
      end
    end
    lens.max
  end

  alias Segment = Tuple(Coord, Coord, Array(Coord), Int32)

  class Node
    property name : String
    property coord : Coord
    property connections : Array(Tuple(Node, Segment)) = [] of Tuple(Node, Segment)

    def initialize(@name, @coord)
    end
  end

  def part2(lines)
    map = Parsers.map(lines)
    ['^','>','v','<'].each do |t|
      map.find_all(t).each { |c| map.set(c, '.') }
    end
    start = { x: 1, y: 0 }
    stop = { x: map.max_x - 1, y: map.max_y }

    debug "finding forks"
    forks = [] of Coord
    forks << start
    map.find_all('.').each do |c|
      if map.neighbors(c).map(&.last).count('.') > 2
        forks << c
      end
    end
    forks << stop

    # DFS to find all segments from fork to fork
    debug "finding segments"
    segments = [] of Segment
    paths = [ [start] ]
    until paths.empty?
      path = paths.pop
      c = path[-1]
      if path.size > 1 && c.in?(forks)
        # found a segment
        s = path[0]
        e = path[-1]
        next if segments.any? { |a,b,p,l| (a==s && b==e) || (a==e && b==s) }
        segments << { s, e, path, path.size }
        map.neighbors(path[-1]).each do |nc, nt|
          next unless map.in_bounds?(nc)
          next if nt == '#'
          next if nc.in?(path)
          paths << [c, nc]
        end
      else
        # keep following path
        t = map.get c
        map.neighbors(path[-1]).each do |nc, nt|
          next unless map.in_bounds?(nc)
          next if nt == '#'
          next if nc.in?(path)
          paths << (path.dup + [nc])
        end
      end
    end

    debug "building nodes from forks"
    nodes = [] of Node
    names = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).map(&.to_s).to_a
    forks.each do |coord|
      node = Node.new(names.shift.to_s, coord)
      nodes << node
    end

    debug "connecting nodes"
    nodes.each do |n|
      nodes.each do |m|
        next if n == m
        next unless segment = segments.find do |a,b,p,l|
          (a == m.coord && b == n.coord) || (a == n.coord && b == m.coord)
        end
        m.connections << { n, segment }
      end
    end

    debug "pathing"
    done_paths = [] of Array(Node)
    node_paths = [ [nodes[0]] ]
    until node_paths.empty?
      node_path = node_paths.pop
      node = node_path[-1]
      if node.coord == stop
        done_paths << node_path
        next
      end
      conn_nodes = node.connections.map(&.first)
      # don't go backwards
      conn_nodes.reject! node_path[-2] if node_path.size > 1
      conn_nodes.each do |conn_node|
        next if conn_node.in?(node_path)
        node_paths << node_path + [conn_node]
      end
    end

    debug "calculating largest"
    paths2 = done_paths.map do |p|
      p_segments = p.each_cons_pair.to_a.map do |n,m|
        n.connections.find! { |o,s| o == m }[1]
      end
      #     segment lengths             - double-count forks    - start square
      len = p_segments.sum { |s| s[3] } - (p_segments.size - 1) - 1
      { p, p_segments, len }
    end

    largest = paths2.max_by(&.last)
    return largest.last

    #path2 = largest[1].map { |a,b,p,l| p }.flatten
    #resolver = ->(c : Coord, t : Char | Nil) : Char | Nil {
    #  c.in?(path2) ? 'O' : (t || '?')
    #}
    #map.draw resolver: resolver
  end
end
