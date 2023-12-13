class Aoc2023::Thirteen < Aoc2023::Solution
  def parse(lines)
    Parsers.groups(lines).compact_map do |g|
      next if g.empty?
      Parsers.map(g)
    end
  end

  def part1(lines)
    maps = parse lines
    maps.sum do |map|
      xr = x_reflection map
      next (xr + 1) if xr
      yr = y_reflection map
      next (yr + 1) * 100 if yr
      raise "none found!"
    end
  end

  def part2(lines)
    maps = parse lines
    maps.each.with_index.sum do |map, i|
      xr = x_reflection map
      yr = y_reflection map
      xr2 = nil
      yr2 = nil
      map.each do |c, t|
        map2 = map.clone
        map2.set(c, t == '#' ? '.' : '#')
        xr2 = x_reflections(map2).reject(xr).shift?
        break if xr2
        yr2 = y_reflections(map2).reject(yr).shift?
        break if yr2
      end
      next (xr2 + 1) if xr2
      next (yr2 + 1) * 100 if yr2
      raise "none found!"
    end
  end

  def x_reflection(map)
    x_reflections(map).shift?
  end

  def y_reflection(map)
    y_reflections(map).shift?
  end

  def x_reflections(map)
    map.min_x.upto(map.max_x-1).select do |i|
      b_r = 0..i
      a_r = (i+1)..map.max_x
      if b_r.size > a_r.size
        b_r = (i - a_r.size + 1)..i
      elsif a_r.size > b_r.size
        a_r = (i+1)..((i+1) + b_r.size - 1)
      end
      before = map.cols(b_r)
      after = map.cols(a_r)
      before == after.reverse
    end.to_a
  end

  def y_reflections(map)
    map.min_y.upto(map.max_y-1).select do |i|
      b_r = 0..i
      a_r = (i+1)..map.max_y
      if b_r.size > a_r.size
        b_r = (i - a_r.size + 1)..i
      elsif a_r.size > b_r.size
        a_r = (i+1)..((i+1) + b_r.size - 1)
      end
      before = map.rows(b_r)
      after = map.rows(a_r)
      before == after.reverse
    end.to_a
  end
end
