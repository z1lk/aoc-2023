module Aoc2023
  abstract class Solution
    def self.variant
      nil
    end

    def self.all
      {{@type.all_subclasses}}
    end

    def self.day_word
      self.to_s.split("::").last
    end

    def self.day_int
      DAYS.index!(day_word) + 1
    end

    def self.day_int_padded
      day_int.to_s.rjust(2, '0')
    end

    def day_word
      self.class.day_word
    end

    def day_int
      self.class.day_int
    end

    def day_int_padded
      self.class.day_int_padded
    end

    def test_input(ver = nil)
      read_input("test", day_int_padded, ver)
    end

    def example_input(ver = nil)
      read_input("example", day_int_padded, ver)
    end

    def real_input(ver = nil)
      read_input("", day_int_padded, ver)
    end

    def read_input(folder : String, day : String | Char, ver : String | Char | Nil = nil)
      path = day.to_s
      path = [folder, path].join("/") if folder
      path = [path, ver].join("-") if ver
      fn = "inputs/#{path}"
      unless File.exists?(fn)
        STDERR.puts "input \"#{path}\" not found!"
        exit 1
      end
      File.read_lines(fn)
    end

    #abstract def parse_input(input)

    abstract def part1(lines)

    abstract def part2(lines)

    def solve(part : Int32, input_type = :real, input_ver = nil)
      input = 
        case input_type
        when :real then real_input(input_ver)
        when :example then example_input(input_ver)
        when :test then test_input(input_ver)
        #when :filename
        #  read_input("", input_ver)
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

    def example(part : Int32, input_ver = nil)
      solve(part, :example, input_ver)
    end

    def test(part : Int32, input_ver = nil)
      solve(part, :test, input_ver)
    end
  end
end
