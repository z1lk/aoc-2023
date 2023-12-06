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

    def test_input(ver)
      read_input("test/#{day_int}#{ver}")
    end

    def example_input(ver)
      read_input("example/#{day_int}#{ver}")
    end

    def real_input(ver)
      read_input("#{day_int}#{ver}")
    end

    def read_input(input : String | Char)
      fn = "inputs/#{input}"
      unless File.exists?(fn)
        STDERR.puts "input \"#{input}\" not found!"
        exit 1
      end
      File.read_lines(fn)
    end

    #abstract def parse_input(input)

    abstract def part1(lines)

    abstract def part2(lines)

    def solve(part : Int32, input_type = :real, input_ver = "")
      input = 
        case input_type
        when :real then real_input(input_ver)
        when :example then example_input(input_ver)
        when :test then test_input(input_ver)
        when :filename then read_input(input_ver)
        else
          raise "unknown input type \"#{input_type}\""
        end
      case part
      when 1 then part1(input)
      when 2 then part2(input)
      end
    end

    def real(part : Int32)
      solve(part)
    end

    def example(part : Int32, input_ver = "")
      solve(part, :example, input_ver)
    end

    def test(part : Int32, input_ver = "")
      solve(part, :test, input_ver)
    end
  end
end
