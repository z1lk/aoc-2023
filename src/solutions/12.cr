class Aoc2023::Twelve < Aoc2023::Solution
  def parse(lines)
    lines.map do |l|
      spr, dmg = l.split
      {spr, dmg.split(',').map(&.to_i)}
    end
  end
  def part1(lines)
    conds = parse lines
    cond = conds[1]
    conds.each.with_index.sum do |cond,i|
      spr, dmg = cond
      vars = variants spr
      pat_s = "\\A\\.*" + dmg.map { |i| "\#{#{i}}" }.join("\\.+") + "\\.*\\z"
      pat = Regex.new(pat_s)
      vars.count { |v| v.matches?(pat) }
    end
  end

  def part2(lines)
  end

  def variants(line)
    # 1,1,3
    un = line.chars.each.with_index.select { |c, i| c == '?' }.map(&.last).to_a
    a = [] of String
    (2 ** un.size).times do |i|
      bin = i.to_s(2).rjust(un.size, '0')
      l = line.dup.chars
      bin.chars.each.with_index do |c, j|
        l[un[j]] = c == '0' ? '.' : '#'
      end
      a << l.join
    end
    a
  end
end
