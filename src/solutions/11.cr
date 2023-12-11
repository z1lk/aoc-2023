class Aoc2023::Eleven < Aoc2023::Solution
  def parse(lines)
    # convert to chars so we can transpose
    lines = lines.map { |l| l.chars }
    lines2 = [] of Array(Char)
    lines.each do |l|
      lines2 << l
      lines2 << l if l.all? { |c| c == '.' }
    end
    lines2 = lines2.transpose
    lines3 = [] of Array(Char)
    lines2.each do |l|
      lines3 << l
      lines3 << l if l.all? { |c| c == '.' }
    end
    map = Map.new(lines3.transpose)
  end

  def part1(lines)
    map = parse lines
    galaxies = map.find_all('#')
    galaxies.combinations(2).sum do |(a,b)|
      map.dist(a,b)
    end
  end

  def part2(lines)
    map = Parsers.map(lines)
    empty_cols = [] of Int32
    empty_rows = [] of Int32
    map.max_x.times do |x|
      chars = 0.to(map.max_y).to_a.map do |y|
        map.get({x: x, y: y})
      end
      empty_cols << x if chars.all? { |c| c == '.' }
    end
    map.max_y.times do |y|
      chars = 0.to(map.max_x).to_a.map do |x|
        map.get({x: x, y: y})
      end
      empty_rows << y if chars.all? { |c| c == '.' }
    end
    galaxies = map.find_all('#')
    galaxies.combinations(2).sum do |(a,b)|
      d = map.dist(a,b).to_i64
      n_empty_cols_crossed = a[:x].to(b[:x]).to_a.&(empty_cols).size
      n_empty_rows_crossed = a[:y].to(b[:y]).to_a.&(empty_rows).size
      d += (1_000_000 * n_empty_cols_crossed) - n_empty_cols_crossed
      d += (1_000_000 * n_empty_rows_crossed) - n_empty_rows_crossed
      d
    end
  end
end
