class Aoc2023::Eleven < Aoc2023::Solution
  def solve(lines, expansion)
    map = Parsers.map(lines)
    empty_x = 0.to(map.max_x).select do |x|
      0.to(map.max_y).all? do |y|
        map.get({x: x, y: y}) == '.'
      end
    end.to_a
    empty_y = 0.to(map.max_y).select do |y|
      0.to(map.max_x).all? do |x|
        map.get({x: x, y: y}) == '.'
      end
    end.to_a
    map.find_all('#').each_combination(2, true).map do |(a,b)|
      d = map.dist(a,b).to_i64
      d += (expansion - 1) * empty_x.count { |n| n.in?(a[:x].to(b[:x])) }
      d += (expansion - 1) * empty_y.count { |n| n.in?(a[:y].to(b[:y])) }
      d
    end.sum
  end

  def part1(lines)
    solve lines, 2
  end

  def part2(lines)
    solve lines, 1_000_000
  end
end
