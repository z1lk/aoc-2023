class Aoc2023::One < Aoc2023::Solution
  def parse_input(input)
    File.read_lines(input)
  end

  WORDS = [ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" ]
  WORDS_R = WORDS.map(&.reverse)

  def part1(input)
    input.map do |str|
      [str.match!(/\d/)[0], str.reverse.match!(/\d/)[0]].join.to_i
    end.sum
  end

  def part2(input)
    input.map do |str|
      [find_digit(str), find_digit(str, true)].join.to_i
    end.sum
  end

  def find_digit(str, last = false)
    str = str.reverse if last
    pats = [/\d/].concat (last ? WORDS_R : WORDS).map { |w| Regex.literal(w) }
    md = pats.compact_map { |p| str.match(p) }.min_by(&.begin)
    m = md[0]
    return m if m.size == 1 # single-digit char
    (last ? WORDS_R : WORDS).index!(m) + 1
  end
end
