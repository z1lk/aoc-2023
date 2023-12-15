class Aoc2023::Twelve < Aoc2023::Solution
  def initialize
    @cache = Hash(Tuple(Int32, Int32, Int32), Int64).new
  end

  def parse(lines)
    lines.map do |l|
      spr, dmg = l.split
      {spr, dmg.split(',').map(&.to_i)}
    end
  end

  def part1(lines)
    conds = parse lines
    conds.sum do |spr, dmg|
      @cache.clear
      arrangements spr, dmg
    end
  end

  def part2(lines)
    conds = parse lines
    conds = conds.map do |spr, dmg|
      { ([spr] * 5).join("?"), dmg * 5 }
    end
    conds.sum do |spr, dmg|
      @cache.clear
      arrangements spr, dmg
    end
  end

  def arrangements(spr, dmg, i = 0, di = 0, blen = 0)
    # debug_line spr, dmg, i, di, blen

    # past end of str
    if i == spr.size
      if spr[i-1] == '#'
        # ended on a block. correct length?
        if di < dmg.size && blen == dmg[di]
          # inc di since that's how we determine win
          di += 1
        else
          return 0_i64
        end
      end
      # made it past the last block ?
      return di > dmg.size - 1 ? 1_i64 : 0_i64
    end

    key = {i,di,blen}
    return @cache[key] if @cache.has_key?(key)

    val =
    case spr[i]
    when '.'
      if blen > 0 # just ended a block
        if di == dmg.size # too many blocks
          0_i64
        elsif blen == dmg[di] # correct block length
          arrangements spr, dmg, i+1, di+1, 0
        else # wrong block length
          0_i64
        end
      else
        arrangements spr, dmg, i+1, di, 0
      end
    when '#'
      arrangements spr, dmg, i+1, di, blen + 1
    else # '?'
      arrangements(spr.sub(i, '.'), dmg, i, di, blen) +
        # important that we increment i/blen here, else it will return
        # the cached result of the above call (would have same key)
        arrangements(spr.sub(i, '#'), dmg, i+1, di, blen + 1)
    end
    @cache[key] = val
  end
end
