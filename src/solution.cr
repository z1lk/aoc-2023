module Aoc2023
  abstract class Solution
    def self.all
      {{@type.all_subclasses}}
    end

    def self.day_word
      self.to_s.split("::").last
    end

    def self.day_int
      DAYS[day_word]
    end

    def day_word
      self.class.day_word
    end

    def day_int
      self.class.day_int
    end

    def test_input
      read_input("test/#{day_int}")
    end

    def example_input(filename : Nil | String = day_int)
      read_input("example/#{filename}")
    end

    def real_input
      read_input(day_int)
    end

    def read_input(input)
      File.read_lines("inputs/#{input}")
    end

    #abstract def parse_input(input)

    abstract def part1(lines)

    abstract def part2(lines)

    def solve(part : Int32, input_type = :real)
      input = 
        case input_type
        when :real then real_input
        when :example then example_input
        when :test then test_input
        when String
          read_input(input_type)
        else
          real_input
        end
      case part
      when 1
        part1 input
      when 2
        part2 input
      end
    end

    def real(part : Int32)
      solve(part)
    end

    def example(part : Int32, input_type = :example)
      if input_type.is_a?(String)
        input_type = "example/#{input_type}"
      end
      solve(part, input_type)
    end

    def test(part : Int32)
      solve(part, :test)
    end
  end
end
