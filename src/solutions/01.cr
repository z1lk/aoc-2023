class Aoc2023::One < Aoc2023::Solution
  def parse_input(input)
    File.read_lines(input).map(&.chars)
  end

  def part1(input)
    input.map do |chars|
      ints = chars.compact_map do |c|
        next unless c.ord >= '1'.ord && c.ord <= '9'.ord
        c
      end
      [ints.first, ints.last].join.to_i
    end.sum
  end

  def part2(input)
    strings = input.map(&.join)
    strings.map do |str|
      [
        first_digit(sub_words(str)),
        first_digit(sub_words(str, true).reverse)
      ].join.to_i
    end.sum
  end

  def first_digit(str)
    str.chars.find do |c|
      next unless c.ord >= '1'.ord && c.ord <= '9'.ord
      c
    end
  end

  def sub_words(str, from_right = false)
    str2 = str.dup
    loop do
      if s = sub_word(str2, from_right)
        str2 = s
      else
        return str2
      end
    end
  end

  NUMS = {
    #"zero" => "0",
    "one" => "1", "two" => "2", "three" => "3", "four" => "4",
    "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9"
  }

  def sub_word(str, from_right = false)
    str = str.dup
    first_w = nil
    first_i = nil
    NUMS.each do |word, digit|
      i = from_right ? str.rindex(word) : str.index(word)
      if i && (first_i.nil? || (from_right ? i > first_i : i < first_i))
        first_i = i
        first_w = word
      end
    end
    if first_w
      return str.sub first_w, NUMS[first_w]
    end
    nil
  end
end
