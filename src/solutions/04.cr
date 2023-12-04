class Aoc2023::Four < Aoc2023::Solution
  def parse_input(input)
    InputParsers.pattern(input, /Card\s+(\d+):((?:\s+\d+)+)\s+\|((?:\s+\d+)+)/) do |m|
      {
        m[1].to_i,
        m[2].strip.split.map(&.to_i),
        m[3].strip.split.map(&.to_i)
      }
    end
  end

  def part1(input)
    input.sum do |(n, a, b)|
      match = a.&(b).size
      next 0 unless match > 0
      2 ** (match - 1)
    end
  end

  def part2(input)
    copies = Hash(Int32, Int32).new(0)
    input.each do |(n, a, b)|
      a.&(b).size.times do |i|
        m = n + (i+1)
        next if m > input.size
        copies[m] += 1 + copies[n]
      end
    end
    input.size + copies.values.sum
  end
end
