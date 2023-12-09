class Aoc2023::Nine < Aoc2023::Solution
  def parse(lines)
    lines.map do |line|
      line.split(' ').map(&.to_i32)
    end
  end

  def part1(lines)
    parse(lines).map { |l| extrapolate(l) }.sum
  end

  def part2(lines)
    parse(lines).map { |l| extrapolate(l, true) }.sum
  end

  def extrapolate(line, left = false)
    return 0 if line.all?(&.zero?)

    diff = line.each_cons_pair.to_a.map { |(a,b)| b - a }
    diff_e = extrapolate(diff, left)
    if left
      line.first - diff_e
    else
      line.last + diff_e
    end
  end
end
