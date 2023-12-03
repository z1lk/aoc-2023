class Aoc2023::Two < Aoc2023::Solution
  alias Hand = Hash(String, Int32)
  def parse_input(input)
    #((?:\d+ \w+,? ?);?)+
    games = Hash(Int32, Array(Hand)).new
    InputParsers.pattern(input, /Game (\d+): (.*)\Z/) do |m|
      gid = m[1].to_i
      games[gid] = [] of Hand
      m[2].split("; ").each do |hand|
        h = Hand.new(0)
        hand.split(", ").each do |x|
          num, color = x.split
          h[color] = num.to_i
        end
        games[gid] << h
      end
    end.to_h
    games
  end

  def part1(input)
    input.select do |id, hands|
      hands.none? do |hand|
        hand["red"] > 12 || hand["green"] > 13 || hand["blue"] > 14
      end
    end.keys.sum
  end

  def part2(input)
    input.map do |id, hands|
      r = g = b = 0
      hands.each do |hand|
        r = [r, hand["red"]].max
        g = [g, hand["green"]].max
        b = [b, hand["blue"]].max
      end
      r * g * b
    end.sum
  end
end
