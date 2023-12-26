class Aoc2023::TwentyFour < Aoc2023::Solution
  # 19, 13, 30 @ -2,  1, -2
  def parse(lines)
    Parsers.pattern(lines, /(\d+), (\d+), (\d+) @ +(-?\d+), +(-?\d+), +(-?\d+)/) do |m|
      px, py, pz, vx, vy, vz = m.captures.compact.map &.to_i128
      { {px, py, pz}, {vx, vy, vz} }
    end
  end

  alias Triord = Tuple(Int128, Int128, Int128)
  alias TriordF64 = Tuple(Float64, Float64, Float64)
  alias Hail = NamedTuple(
    id: Int32,
    name: String,
    pos: Triord,
    vel: Triord,
    slope: Float64,
    intercept: Float64,
    zslope: Float64,
    zintercept: Float64
  )

  def analyze(hail)
    name_strings = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a
    name_strings = name_strings.map &.to_s
    names = name_strings.map { |s| [s] }
    i = 1
    if names.size < hail.size
      i += 1
      names = name_strings.combinations(i)
    end
    i = 0
    hail.map do |h|
      id = i
      i += 1
      p, v = h
      # y = m*x + b
      # m = vy / vx
      m = v[1] / v[0]
      # b = y - mx
      b = p[1] - (m * p[0])

      zm = v[2] / v[0]
      zb = p[2] - (zm * p[0])
      {
        id: id,
        name: names.shift.join,
        pos: p,
        vel: v,
        slope: m,
        intercept: b,
        zslope: zm,
        zintercept: zb
      }
    end
  end

  def part1(lines)
    hail = parse lines

    min, max =
      case self.input_type
      when :example
        { 7, 27 }
      when :real
        { 200000000000000, 400000000000000 }
      else raise "set input type for TwentyFour#part1"
      end
    area = min..max

    hail = analyze hail

    hail.combinations(2).sum do |(a,b)|
      debug_line a[:name], a[:pos], a[:vel]
      debug_line b[:name], b[:pos], b[:vel]

      if a[:slope] == b[:slope] # parallel
        debug "parallel"
        next 0 
      end

      # y = ma * x + ia
      # y = mb * x + ib
      # ma * x + ia = mb * x + ib
      # ma * x - mb * x = ib - ia
      # x = (ib - ia) / (ma - mb)
      x = (b[:intercept] - a[:intercept]) / (a[:slope] - b[:slope])
      y = a[:slope] * x + a[:intercept]
      debug "cross at #{x},#{y}"

      unless x.in?(area)
        debug "x outside area (#{x})"
        next 0 
      end
      unless y.in?(area)
        debug "y outside area (#{y})"
        next 0
      end

      # x = t * vx + px
      # t * vx = x - px
      # t = (x - px) / vx
      #a_future = (va[0] / (x - pa[0])).positive?
      #unless a_future
      ta = (x - a[:pos][0]) / a[:vel][0]
      if ta < 0
        debug "past for A"
        next 0
      end
      #b_future = (vb[0] / (x - pb[0])).positive?
      #unless b_future
      tb = (x - b[:pos][0]) / b[:vel][0]
      if tb < 0
        debug "past for B"
        next 0
      end

      1

      # ax + c = bx + d
      # ax - bx = d - c
      # x = (d - c) / (a - b)

      # ma 
    end
  end

  def pos_at(h : Hail, t : Int128)
    # x = t * vx + px
    {
      t * h[:vel][0] + h[:pos][0],
      t * h[:vel][1] + h[:pos][1],
      t * h[:vel][2] + h[:pos][2]
    }
  end

  def dist_at(pos : Triord, h : Hail, t : Int128)
    ph = pos_at h, t
    [
      (pos[0] - ph[0]).abs,
      (pos[1] - ph[1]).abs,
      (pos[2] - ph[2]).abs
    ].sum
  end

  def dist(hpos : Triord, gpos : Triord)
    [
      (gpos[0] - hpos[0]).abs,
      (gpos[1] - hpos[1]).abs,
      (gpos[2] - hpos[2]).abs
    ].sum
  end
  
  def part2(lines)
    hail = parse lines
    hail = analyze hail
    min_x = hail.map { |h| h[:pos][0] }.min
    max_x = hail.map { |h| h[:pos][0] }.max
    min_y = hail.map { |h| h[:pos][1] }.min
    max_y = hail.map { |h| h[:pos][1] }.max
    min_z = hail.map { |h| h[:pos][2] }.min
    max_z = hail.map { |h| h[:pos][2] }.max
    debug_line "min x", min_x
    debug_line "max x", max_x
    debug_line "min y", min_y
    debug_line "max y", max_y
    debug_line "min z", min_z
    debug_line "max z", max_z
    x_step = (max_x - min_x) // 20
    y_step = (max_y - min_y) // 20
    z_step = (max_z - min_z) // 20
    x_a = [min_x]
    until x_a[-1] > max_x
      x_a += [x_a[-1] + x_step] 
    end
    y_a = [min_y]
    until y_a[-1] > max_y
      y_a += [y_a[-1] + y_step] 
    end
    z_a = [min_z]
    until z_a[-1] > max_z
      z_a += [z_a[-1] + z_step] 
    end

    cubes = [] of { Triord, Triord, Array(String) }

    x_a.each_cons_pair do |x, x2|
      y_a.each_cons_pair do |y, y2|
        z_a.each_cons_pair do |z, z2|
          arr = [] of String
          hail.each do |h|
            next unless h[:pos][0] >= x && h[:pos][0] <= x2
            next unless h[:pos][1] >= y && h[:pos][1] <= y2
            next unless h[:pos][2] >= z && h[:pos][2] <= z2
            arr << h[:name]
          end
          cubes << { {x,y,z}, {x2,y2,z2}, arr }
        end
      end
    end

    sorted = cubes.sort_by { |c, c2, arr| arr.size }.reverse
    sorted.each do |c, c2, arr|
      next unless arr.any?
      #debug_line c, c2, arr
    end

    # {292979059726933, 279196087498906, 245379010517659} / {318068352868377, 306778998115266, 272493241744889} / ["AM", "Bj", "CW", "E6"]
    stones = ["AM", "Bj", "CW", "E6"].map do |name|
      h = hail.find! { |h| h[:name] == name }
      debug_line h[:name], h[:pos], h[:vel]
      h
    end

    # AM / {311130681683078, 306087457111806, 249396912802046} / {-6, 76, 88}
    # Bj / {305652996804134, 286453493146902, 264981285923474} / {-28, -10, -14}
    # CW / {311742164640651, 291451783752287, 260659403365957} / {-20, 46, 42}
    # E6 / {293454485170041, 289158835902427, 267387384549817} / {-9, -32, -32}

    moving_closer = [] of Tuple(Hail, Hail)

    stones.each_combination(2) do |(h, g)|
      ph0 = pos_at h, 0
      pg0 = pos_at g, 0
      ph1 = pos_at h, 1
      pg1 = pos_at g, 1

      if dist(ph1, pg1) < dist(ph0, pg0)
        moving_closer << { h, g }
      end
    end

    #moving_closer.each do |h,g|
    #  debug_line h[:name], g[:name]
    #end
    # AM / CW
    # AM / E6
    # Bj / E6
    # CW / E6

    hE6 = stones.find! { |s| s[:name] == "E6" }
    g = hE6
    others = stones.select { |s| s[:name] != "E6" }

    t_apart = [] of { Int128, Int128 }
    
    others.each do |h|
      t = 0_i128
      ph_last = nil
      pg_last = nil
      loop do 
        debug_line "t", t if t % 100_000 == 0
        ph = pos_at h, t
        pg = pos_at g, t
        if ph_last && pg_last
          if dist(ph, pg) > dist(ph_last, pg_last)
            t_apart << { t, dist(ph, pg) }
            break
            #raise "moving apart at t=#{t}"
          end
        end
        ph_last = ph
        pg_last = pg
        t += 500000
      end
    end

    t_apart

    # 149921000000
    # 133672500000
    #  90919000000

    #hail.sort_by { |h| h[:vel] }.each do |h|
    #  debug_line h[:pos], h[:vel]
    #end
    #a = hail[0]
    #b = hail[1]
    #c = hail[2]
  end

  def part2_d(lines)
    hail = parse lines
    hail = analyze hail
    a = hail[0]
    not_a = hail.reject(a)

    start = 0_i128
    stop = 100_000_000_000_i128
    step = 100_000_i128
    avg_dists = [] of Tuple(Int128, Float64)

    t = start
    until t > stop
      debug t
      pa = pos_at a, t
      avg_dist = not_a.sum { |h| dist_at(pa, h, t) } / not_a.size
      avg_dists << { t, avg_dist }
      t += step
    end

    avg_dists_sorted = avg_dists.sort_by { |t,d| d }
    debug avg_dists_sorted.first(10)
    debug avg_dists_sorted.last

    return 

    # time, vel through a at t
    possible = [] of Tuple(Int128, TriordF64)

    #max_t = 100_000_000_000_000_i128
    #r = Random.new
    #nums = 10_000.times.map { r.rand(max_t) }.to_a
    #debug nums
    #nums.each do |t|
    #start.to(start + t_max) do |t|
    # closest (taxicab) any other hailstone gets at every t
    closests = [] of Tuple(Int128, Int128)

      #debug_line "t", t #if t % 1_000 == 0
      #pa = pos_at a, t
      #not_a_pos = not_a.map { |h| pos_at(h, t) }
      #dists = not_a_pos.map do |ph|
      #  [
      #    (pa[0] - ph[0]).abs,
      #    (pa[1] - ph[1]).abs,
      #    (pa[2] - ph[2]).abs
      #  ].sum
      #end
      #closests << { t, dists.min }
    #end

    closests_sorted = closests.sort_by { |t,d| d }
    debug closests_sorted.first(10)
    debug closests_sorted.last

    #debug closests
    return

    debug "assessing possible t/vel (#{possible.size})"
    i = 0_i128
    possible.each do |(t, vel)|
      i += 1
      #debug_line "possible", t, vel
      debug_line "possible", i if i % 1000 == 0
      vx, vy, vz = vel
      pa = pos_at a, t
      px, py, pz = pa

      # y = mx + b
      # m = dy/dx
      m = vy / vx
      # b = y - mx
      b = py - (m * px)
      zm = vz / vx
      zb = pz - (zm * px)

      # x = u * vx + px
      # y = u * vy + py
      # z = u * vz + pz
      # where u is time after t
      next unless hail.all? do |h|
        (0..t_max).to_a.map(&.to_i128).any? do |q|
          u = q - t # e.g. t=2 q=5 u=3, t=5 q=2 u=-3
          x = u * vx + px
          y = u * vy + py
          z = u * vz + pz
          pos_at(h, q) == {x,y,z}
        end
      end
      u = t * -1
      p0x = u * vx + px
      p0y = u * vy + py
      p0z = u * vz + pz
      #puts p0x, p0y, p0z
      puts t, vel
      return [ p0x, p0y, p0z ].sum
    end
  end

  def part2_c(lines)
    hail = parse lines
    hail = analyze hail
    a = hail[0]
    b = hail[1]
    c = hail[2]

    # time, vel through a at t
    possible = [] of Tuple(Int128, TriordF64)

    t_max = 1_000_i128
    0_i128.to(t_max) do |t|
      debug_line "t", t if t % 1_000 == 0
      break if possible.any?
      pa = pos_at a, t
      0_i128.to(t_max) do |tb|
        debug_line "tb", tb if tb % 1_000 == 0
        break if possible.any?
        next if tb == t
        pb = pos_at b, tb
        pb_diff = { pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2] }
        tb_diff = tb - t
        bvel = { pb_diff[0] / tb_diff, pb_diff[1] / tb_diff, pb_diff[2] / tb_diff }

        # if tb is after t, e.g. t=2 tb=4, then we multiply -1 * t, e.g. -2, by the position of a @ t, to get the position of the rock at t=0
        u = t * -1
        p0x = u * bvel[0] + pa[0]
        p0y = u * bvel[1] + pa[1]
        p0z = u * bvel[2] + pa[2]

        # we know the answer will be a set of integers. this tests for decimal part.
        next unless p0x % 1 == 0 && p0y % 1 == 0 && p0z % 1 == 0

        # do the same for c. if a, b, and c all fit a line, then we have a canditate for a line through all.
        0_i128.to(t_max) do |tc|
          #debug_line "tc", tc if tc % 50_000 == 0
          next if tc == t || tc == tb
          pc = pos_at c, tc
          pc_diff = { pc[0] - pa[0], pc[1] - pa[1], pc[2] - pa[2] }
          tc_diff = tc - t
          cvel = { pc_diff[0] / tc_diff, pc_diff[1] / tc_diff, pc_diff[2] / tc_diff }

          if cvel == bvel
            possible << { t, cvel }
            break #if possible.any?
          end
        end
      end
    end

    debug "assessing possible t/vel (#{possible.size})"
    i = 0_i128
    possible.each do |(t, vel)|
      i += 1
      #debug_line "possible", t, vel
      debug_line "possible", i if i % 1000 == 0
      vx, vy, vz = vel
      pa = pos_at a, t
      px, py, pz = pa

      # y = mx + b
      # m = dy/dx
      m = vy / vx
      # b = y - mx
      b = py - (m * px)
      zm = vz / vx
      zb = pz - (zm * px)

      # x = u * vx + px
      # y = u * vy + py
      # z = u * vz + pz
      # where u is time after t
      next unless hail.all? do |h|
        (0..t_max).to_a.map(&.to_i128).any? do |q|
          u = q - t # e.g. t=2 q=5 u=3, t=5 q=2 u=-3
          x = u * vx + px
          y = u * vy + py
          z = u * vz + pz
          pos_at(h, q) == {x,y,z}
        end
      end
      u = t * -1
      p0x = u * vx + px
      p0y = u * vy + py
      p0z = u * vz + pz
      #puts p0x, p0y, p0z
      puts t, vel
      return [ p0x, p0y, p0z ].sum
    end
  end

  def part2_b(lines)
    hail = parse lines
    hail = analyze hail
    a = hail[0]

    pos_at = ->(h : Hail, t : Int128) do
      # x = t * vx + px
      {
        t * h[:vel][0] + h[:pos][0],
        t * h[:vel][1] + h[:pos][1],
        t * h[:vel][2] + h[:pos][2]
      }
    end

    ax,ay,az = a[:pos]
    avx, avy, avz = a[:vel]

    # time, vel through a at t
    possible = [] of Tuple(Int128, TriordF64)

    not_a = hail.reject(a)

    debug "finding possible t/vel"
    win_size = 250_i128
    #t_max = 100_000_i128
    #t_max = 10_i128
    t_max = win_size * (hail.size * 1.5)
    debug_line "t_max", t_max
    0_i128.to(t_max) do |t|
      debug_line "t", t if t % 1_000 == 0
      # debug_line "t", t
      win_min = [t - win_size, 0_i128].max
      win_max = [t + win_size, t_max].min
      pa = pos_at.call(a, t)
      win_min.to(win_max) do |t2|
        next if t2 == t
        not_a_pos = not_a.map do |h| 
          pos_at.call(h, t2)
        end
        pb = not_a_pos.min_by do |ph|
          [
            (pa[0] - ph[0]).abs,
            (pa[1] - ph[1]).abs,
            (pa[2] - ph[2]).abs
          ].sum
        end
        v = { pb[0] - pa[0], pb[1] - pa[1], pb[2] - pa[2] }
        t_diff = t2 - t
        vel = { v[0] / t_diff, v[1] / t_diff, v[2] / t_diff }

        u = t * -1
        p0x = u * vel[0] + pa[0]
        p0y = u * vel[1] + pa[1]
        p0z = u * vel[2] + pa[2]
        
        next unless p0x % 1 == 0
        next unless p0y % 1 == 0
        next unless p0z % 1 == 0

        possible << { t, vel }
      end
    end

    debug "assessing possible t/vel (#{possible.size})"
    i = 0_i128
    possible.each do |(t, vel)|
      i += 1
      #debug_line "possible", t, vel
      debug_line "possible", i if i % 1000 == 0
      vx, vy, vz = vel
      pa = pos_at.call(a, t)
      px, py, pz = pa

      # y = mx + b
      # m = dy/dx
      m = vy / vx
      # b = y - mx
      b = py - (m * px)
      zm = vz / vx
      zb = pz - (zm * px)

      # x = u * vx + px
      # y = u * vy + py
      # z = u * vz + pz
      # where u is time after t
      next unless hail.all? do |h|
        # parallel
        #next false if m == h[:slope] && zm == h[:zslope]
        #x = (h[:intercept] - b) / (m - h[:slope])
        #y = m * x + b
        #z = (h[:zintercept] - zb) / (zm - h[:zslope])
        #y2 = zm * z + zb
        #next unless y == y2
        # x = t * vx + px
        # t * vx = x - px
        # t = (x - px) / vx
        # th = (x - h[:pos][0]) / a[:vel][0]
        
        (0..t_max).to_a.map(&.to_i128).any? do |q|
          u = q - t # e.g. t=2 q=5 u=3, t=5 q=2 u=-3
          x = u * vx + px
          y = u * vy + py
          z = u * vz + pz
          pos_at.call(h, q) == {x,y,z}
        end
      end
      u = t * -1
      p0x = u * vx + px
      p0y = u * vy + py
      p0z = u * vz + pz
      #puts p0x, p0y, p0z
      puts t, vel
      return [ p0x, p0y, p0z ].sum
    end
  end
end
