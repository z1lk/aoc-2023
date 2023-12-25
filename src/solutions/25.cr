class Aoc2023::TwentyFive < Aoc2023::Solution
  class Component
    getter name : String
    property conns : Array(Component)
    def initialize(@name)
      @conns = [] of Component
    end
  end

  def parse(lines)
    # jqt: rhn xhk nvd
    comps_conns = lines.map do |line|
      comp, conns = line.split(": ")
      { comp, conns.split(" ") }
    end.to_h
    comps = comps_conns.map(&.to_a).flatten.uniq.map { |c| Component.new(c) }
    comps_conns.each do |comp_name, conn_names|
      comp = comps.find! { |c| c.name == comp_name }
      conn_names.map do |conn_name|
        conn = comps.find! { |c| c.name == conn_name }
        comp.conns << conn unless conn.in? comp.conns
        conn.conns << comp unless comp.in? conn.conns
      end
    end
    comps
  end

  # Dijkstra's algo with separate seen & unvisited lists to lower time to prioritize next node
  def pathfind(components, start, dest)
    visited = [] of Tuple(Component, Int32, Array(Component))
    unvisited = [] of Tuple(Component, Int32, Array(Component))
    seen = [] of Tuple(Component, Int32, Array(Component))
    components.each do |c|
      next if c == start
      unvisited << { c, Map::UNREACHABLE, [] of Component }
    end
    cur = { start, 0, [] of Component }
    loop do
      cur[0].conns.each do |conn|
        if i = seen.index { |c,d,p| c == conn }
          node = seen[i]
          next unless cur[1] + 1 < node[1] # cur path lt existing path
          seen[i] = { node[0], cur[1] + 1, cur[2] + [cur[0]] }
          next
        end
        i = unvisited.index { |c,d,p| c == conn }
        next unless i # already visited
        node = unvisited.delete_at i
        seen << { node[0], cur[1] + 1, cur[2] + [cur[0]] }
      end
      visited << cur
      return false if seen.none?
      seen.sort_by! { |u| u[1] }
      cur = seen.shift
      # return path to dest
      return cur[2] if cur[0] == dest
    end
  end

  def part1(lines)
    comps = parse lines

    # given the way the problem is state, we know there are two large clusters
    # of components connected by exactly three wires. so we sample nodes at random
    # and pathfind between the two. given one node A, then chances of B being in
    # other cluster is 50%, meaning a path would need to go through one of the three
    # bridges between the two clusters.
    paths = [] of Array(String)
    i = 0
    sample_size = 500
    while i < sample_size
      a,b = comps.sample(2)
      next if b.in? a.conns
      # debug_line "sample pathfind #{i}", "#{a.name}->#{b.name}"
      comp_path = pathfind comps, a, b
      raise "fail pathfind #{a.name}->#{b.name}" unless comp_path.is_a?(Array)
      comp_path.shift # remove the beginning node (a) as this doesn't give useful information about which wire to cut
      # convert path of comps (nodes) to wires (edges)
      p = [] of String
      comp_path.each_cons_pair do |a,b|
        # sort names so that the edges (wires) have the same name regardless of direction
        p << [a.name, b.name].sort.join("/")
      end
      paths << p
      # debug "path #{p}"
      i += 1
    end

    # flatten paths to a list of wires and find the three most seen
    paths = paths.flatten
    unique_paths = paths.uniq
    freqs = unique_paths.map { |p| { p, paths.count(p) } }.sort_by(&.last).reverse.to_h
    bridges = freqs.keys.first(3)

    # sever the connections
    bridges.each do |bridge|
      a_name, b_name = bridge.split("/")
      a = comps.find! { |c| c.name == a_name }
      b = comps.find! { |c| c.name == b_name }
      # debug "disconnecting #{a.name}/#{b.name}"
      a.conns.delete b
      b.conns.delete a
    end

    # take the first severed connection and get the node on either side,
    # which are necessarily in separate clusters, and determine cluster size.
    pair = bridges[0].split("/").map { |n| comps.find! { |c| c.name == n } }
    c1_size = cluster_size(pair[0])
    # debug c1_size
    c2_size = cluster_size(pair[1])
    # debug c2_size
    c1_size * c2_size
  end

  # BFS to explore all connected comps and determine cluster size
  def cluster_size(component)
    cluster = [] of Component
    seen = [ component ] 
    until seen.empty?
      comp = seen.shift
      comp.conns.each do |conn|
        seen << conn unless conn.in?(cluster) || conn.in?(seen)
      end
      cluster << comp
    end
    # debug cluster.map(&.name)
    cluster.size
  end

  def part2(lines)
  end
end
