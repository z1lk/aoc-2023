class Aoc2023::Three < Aoc2023::Solution
  def parse_input(input)
    Map(Char).new(InputParsers.map(input))
  end

  def part1(input)
    map = input
    nums = get_nums(map)
    parts = [] of Int32
    nums.each do |start, len|
      sym = false
      len.times do |offset|
        cur = {x: start[:x]+offset, y: start[:y]}
        map.neighbors(cur, diagonal: true).each do |n|
          next unless (chars = map.get(n)).any?
          c = chars[0]
          sym = true if c != '.' && !c.to_s.matches?(/\d/)
        end
      end
      parts << num_to_int(map, start, len) if sym
    end
    parts.sum
  end

  def part2(input)
    map = input
    nums = get_nums(map)
    ratios = [] of Int32
    map.find_all('*').each do |coord|
      touch = nums.select do |start, len|
        #next unless start[:y].in?([coord[:y], coord[:y] - 1, coord[:y] + 1])
        next unless ((coord[:y] - 1)..(coord[:y] + 1)).covers?(start[:y])
        next true if (coord[:x]..(coord[:x] + 1)).covers?(start[:x])
        next true if (start[:x] >= coord[:x] - len) && start[:x] < coord[:x]
        false
      end.to_a
      next unless touch.size == 2
      ratios << num_to_int(map, *touch[0]) * num_to_int(map, *touch[1])
    end
    ratios.sum
  end

  # identify all numbers on the map by pos of first digit and len
  def get_nums(map)
    nums = Hash(Coords, Int32).new # start, len
    map.each do |coord, char|
      next unless char.to_s.matches?(/\d/)
      left = map.get({x: coord[:x] - 1, y: coord[:y]})
      next if left.to_s.matches?(/\d/)
      right = char
      len = 0
      until !right.to_s.matches?(/\d/)
        len += 1
        right = map.get({x: coord[:x] + len, y: coord[:y]})
      end
      nums[coord] = len
    end
    nums
  end

  # converts start/len found by get_nums to integer values
  def num_to_int(map, start, len)
    len.times.reduce("") do |s, i|
      s + map.get({x: start[:x]+i, y: start[:y]})[0]
    end.to_i
  end
end
