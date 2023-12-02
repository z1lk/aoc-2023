class Aoc2023::Two < Aoc2023::Solution
  def parse_input(input)
    #((?:\d+ \w+,? ?);?)+
    games = Hash(Int32, Array(Hash(String, Int32))).new
    InputParsers.pattern(input, /Game (\d+): (.*)\Z/) do |m|
      gid = m[1].to_i
      games[gid] = [] of Hash(String, Int32)
      m[2].split("; ").each do |hand|
        h = Hash(String, Int32).new
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
        (hand.has_key?("red") && hand["red"] > 12) ||
        (hand.has_key?("green") && hand["green"] > 13) ||
        (hand.has_key?("blue") && hand["blue"] > 14)
      end
    end.keys.sum
  end

  def part2(input)
    input.map do |id, hands|
      min_r = 0
      min_g = 0
      min_b = 0
      hands.each do |hand|
        min_r = hand["red"] if hand.has_key?("red") && min_r < hand["red"]
        min_g = hand["green"] if hand.has_key?("green") && min_g < hand["green"]
        min_b = hand["blue"] if hand.has_key?("blue") && min_b < hand["blue"]
      end
      min_r * min_g * min_b
    end.sum
  end
end
