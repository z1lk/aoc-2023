class Aoc2023::Eight < Aoc2023::Solution
  def parse(lines)
    inst, network = Parsers.groups(lines)
    network = Parsers.pattern(network, /(\w+) = \((\w+), (\w+)\)/) do |m|
      {m[1], m[2], m[3]}
    end
    {inst[0].chars, network}
  end

  def part1(lines)
    inst, network = parse lines
    steps = 0
    cur = "AAA"
    inst.cycle do |i|
      steps += 1
      node = network.find! { |n| n[0] == cur }
      cur = i == 'L' ? node[1] : node[2]
      break if cur == "ZZZ"
    end
    steps
  end

  def part2(lines)
    inst, network = parse lines
    a_nodes = network.map(&.first).select { |n| n.matches?(/A$/) }
    z_nodes = network.map(&.first).select { |n| n.matches?(/Z$/) }
    z_steps = Hash(String, Hash(Int32, String)).new
    a_nodes.each do |a|
      z_steps[a] = Hash(Int32, String).new
      steps = 0
      cur = a
      inst.cycle do |i|
        steps += 1
        node = network.find! { |n| n[0] == cur }
        cur = i == 'L' ? node[1] : node[2]
        z_steps[a][steps] = cur if cur.in?(z_nodes)
        break if z_steps[a].values.count(cur) > 1 # seen this z node before, we're looping
      end
    end
    # each path loops on a single Z node with no "entry" path before looping
    # {
    #   "AAA" => {17873 => "ZZZ", 35746 => "ZZZ"},
    #   "QRA" => {19631 => "XVZ", 39262 => "XVZ"},
    #   "KQA" => {17287 => "QQZ", 34574 => "QQZ"},
    #   "DFA" => {12599 => "VGZ", 25198 => "VGZ"},
    #   "DBA" => {21389 => "PPZ", 42778 => "PPZ"},
    #   "HJA" => {20803 => "QFZ", 41606 => "QFZ"}
    # }
    # so take the first step counters as periods and find the LCM among them all
    ends = z_steps.values.map { |i| i.keys.first.to_i128 }
    ends.reduce(1_i128) { |m, n| m.lcm(n) }
  end

  # nope
  def part2_brute(lines)
    inst, network = parse lines
    curs = network.select { |n| n[0].matches?(/A$/) }.map(&.first)
    stops = network.select { |n| n[0].matches?(/Z$/) }.map(&.first)
    steps = 0
    inst.cycle do |i|
      steps += 1
      curs.map! do |cur|
        node = network.find! { |n| n[0] == cur }
        i == 'L' ? node[1] : node[2]
      end
      break if curs.all? { |c| c.in?(stops) }
    end
    steps
  end
end
