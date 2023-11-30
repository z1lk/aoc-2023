module Aoc2023
  abstract class Solution
    def day_word
      self.class.to_s.split("::").last
    end

    def day_int
      DAYS[day_word]
    end

    def test_input
      parse_input("inputs/test/#{day_int}")
    end

    def example_input(filename : Nil | String = nil)
      filename ||= day_int
      parse_input("inputs/example/#{filename}")
    end

    def real_input
      parse_input("inputs/#{day_int}")
    end

    def input(path)
      parse_input("inputs/#{path}")
    end

    abstract def parse_input(input)

    abstract def part1(input)

    abstract def part2(input)

    def solution(input_type = :real)
      input = 
        case input_type
        when :real
          real_input
        when :example
          example_input
        when :test
          test_input
        else
          input_type = :real
          real_input
        end
      puts "== Day #{day_word}, #{input_type} input =="
      puts "\nPart one:", part1(input.dup)
      puts "\nPart two:", part2(input.dup)
    end
  end
end
