class Aoc2023::TwentyOne < Aoc2023::Solution
  def part1(lines)
    map = Parsers.map(lines)
    start = map.find!('S')
    map.set(start, '.')
    plots = map.find_all('.')
    map.to_s

    steps = 64
    map.set(start,'O')
    steps.times do |step|
      # clone and reset the map
      map2 = map.clone
      map2.find_all('O').each do |c|
        map2.set(c, '.')
      end
      map.find_all('O').each do |c|
        map.neighbors(c).each do |(d,t)|
          next if t == '#'
          next unless map.in_bounds?(d)
          map2.set(d, 'O')
        end
      end
      map = map2
      #debug map.to_s
    end
    map.find_all('O').size
  end

  def part2(lines)
  end
end
