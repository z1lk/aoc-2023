class Aoc2023::Nine < Aoc2023::Solution
  def parse(lines)
    lines.map { |l| l.split.map(&.to_i) }
  end

  def part1(lines)
    parse(lines).sum { |l| extrapolate(l) }
  end

  def part2(lines)
    parse(lines).sum { |l| extrapolate(l.reverse) }
  end

  def extrapolate(line)
    return 0 if line.all?(&.zero?)

    diff = line.each_cons_pair.to_a.map { |(a,b)| b - a }
    line.last + extrapolate(diff)
  end
end
