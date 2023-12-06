module Aoc2023
  class Parsers
    def self.map(lines)
      map = Array(Array(Char)).new
      lines.map do |line|
        map << line.chars
      end
      Map.new(map)
    end
    def self.pattern(lines, pattern)
      lines.compact_map do |line|
        m = line.match(pattern)
        m.nil? ? nil : yield(m)
      end
    end
    def self.groups(lines)
      groups = [] of Array(String)
      lines.each do |line|
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
