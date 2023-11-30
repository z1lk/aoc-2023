module Aoc2023
  class InputParsers
    def self.map(file)
      map = Array(Array(Char)).new
      File.read_lines(file).map do |line|
        map << line.chars
      end
      map
    end
    def self.pattern(file, pattern)
      File.read_lines(file).compact_map do |line|
        m = line.match(pattern)
        m.nil? ? nil : yield(m)
      end
    end
    def self.groups(file)
      groups = [] of Array(String)
      File.read_lines(file).each do |line|
        if line.strip.empty?
          groups << [] of String
          next
        end
        if groups.empty?
          groups << [] of String
        end
        groups[-1] = groups[-1] + [line]
      end
      groups
    end
  end
end
