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
    hail.map do |h|
      p, v = h
      # y = m*x + b
      # m = vy / vx
      m = v[1] / v[0]
      # b = y - mx
      b = p[1] - (m * p[0])

      zm = v[2] / v[0]
      zb = p[2] - (zm * p[0])
      {
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
    #min, max = 7, 27
    min, max = 200000000000000, 400000000000000
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

  def part2(lines)
    hail = parse lines
    hail = analyze hail
    a = hail[0]
    #b = hail[1]

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
    #bvx, bvy, bvz = b[:vel]

    # time, vel through a at t
    #possible = [] of Tuple(Int128, Triord)
    possible = [] of Tuple(Int128, TriordF64)

    not_a = hail.reject(a)

    #(5..6).to_a.map(&.to_i128).each_permutation(2) do |(t,t2)|
    #(0..10).to_a.map(&.to_i128).each_permutation(2) do |(t,t2)|
    debug "finding possible t/vel"
    t_perms = (0..5000).to_a.map(&.to_i128).each_permutation(2).to_a
    #t_perms = (0..100000).to_a.map(&.to_i128).each_cons_pair.to_a
    t_perms.each.with_index do |(t,t2), i|
      debug "#{i}/#{t_perms.size}" if i % 10000 == 0
      pa = pos_at.call(a, t)
      b = not_a.min_by do |h| 
        ph = pos_at.call(h, t2)
        [
          (pa[0] - ph[0]).abs,
          (pa[1] - ph[1]).abs,
          (pa[2] - ph[2]).abs
        ].sum
      end
      pb = pos_at.call(b, t2)
      # FIXME vel needs to account for t diff negative or > 1?
      possible << (
        {
          t,
          {
            (pb[0] - pa[0]) / (t2 - t),
            (pb[1] - pa[1]) / (t2 - t),
            (pb[2] - pa[2]) / (t2 - t)
          }
        }
      )
    end
    #puts possible
    #ex = { 5_i128, { -3_i128, 1_i128, 2_i128 } }
    #raise "not good" unless ex.in?(possible)

    #(0..10).to_a.map(&.to_i128).each_permutation(2) do |(t,t2)|
    #  pa = pos_at.call(a, t)
    #  pb = pos_at.call(b, t2)
      # y = mx + b
      # m = (y2 - y1) / (x2 - x1)
      # b = y - mx
    #  ym = (pb[1] - pa[1]) / (pb[0] - pa[0])
    #  yb = pa[1] - ym * pa[0]
    #  zm = (pb[2] - pa[2]) / (pb[0] - pa[0])
    #  zb = pa[2] - zm * pa[0]
    #  t3 = (t - t2).abs + [t,t2].max
    #  hail.each do |c|
    #    pc = pos_at.call(c, t3)
        # y = mx + b
    #    if pc[1] == ym * pc[0] + yb
    #      if pc[2] == zm * pc[0] + zb
            #debug_line "vx", pb[0] - pa[0], "vy", pb[1] - pa[1], "vz", pb[2] - pa[2]
            #debug_line "vx", pc[0] - pb[0], "vy", pc[1] - pb[1], "vz", pc[2] - pb[2]
    #        vel = {
    #          pb[0].to_i128 - pa[0],
    #          pb[1].to_i128 - pa[1],
    #          pb[2].to_i128 - pa[2]
    #        }
    #        possible << { t, vel }
    #        #raise "FOUND t=#{t} t2=#{t2} t3=#{t3}"
    #      end
    #    end
    #  end
    #end

    #possible.clear
    #possible << { 5_i128, { -3_i128, 1_i128, 2_i128 } }

    debug "assessing possible t/vel"
    possible.each do |(t, vel)|
      debug_line "possible", t, vel
      vx, vy, vz = vel
      pa = pos_at.call(a, t)
      px, py, pz = pa
      # x = u * vx + px
      # y = u * vy + py
      # z = u * vz + pz
      # where u is time after t
      #debug_line "min_t", min_t, "max_t", max_t
      through = hail.all? do |h|
        (0..10).to_a.map(&.to_i128).any? do |q|
          #debug_line "min_t", min_t, "max_t", max_t
          u = q - t # e.g. t=2 q=5 u=3, t=5 q=2 u=-3
          x = u * vx + px
          y = u * vy + py
          z = u * vz + pz
          pos_at.call(h, q) == {x,y,z}
        end
      end
      next unless through
      u = t * -1
      p0x = u * vx + px
      p0y = u * vy + py
      p0z = u * vz + pz
      #return { p0x, p0y, p0z }
      return [ p0x, p0y, p0z ].sum
    end

    #parallel = [] of Tuple(String, String)
    #hail.each_combination(2) do |(a,b)|
    #debug_line a[:name], a[:pos], a[:vel]
    #debug_line b[:name], b[:pos], b[:vel]
    #dvx = a[:vel][0] - b[:vel][0]
    #dvy = a[:vel][1] - b[:vel][1]
    #dvz = a[:vel][2] - b[:vel][2]
    #debug_line "dvx", dvx, "dvy", dvy, "dvz", dvz
    #if a[:slope] == b[:slope] && a[:zslope] == b[:zslope]
    #  parallel << { a[:name], b[:name] }
    #end
    #end
    #parallel
  end
end
