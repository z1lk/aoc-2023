class Aoc2023::TwentyTwo < Aoc2023::Solution
  alias Triord = Tuple(Int32, Int32, Int32)
  alias Brick = Array(Triord)

  # parse the bricks from start~end into a list of its coordinates by filling out the middle cells
  def parse(lines)
    bricks = Parsers.pattern(lines, /(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/) do |m|
      c = m.captures.compact.map(&.to_i32)
      s = { c[0], c[1], c[2] } # start
      e = { c[3], c[4], c[5] } # end
      cells = [s]
      if s != e # if start != end then the brick is at least 2 wide
        # find the axis that s/e differ in, and iterate from s/e on that axis,
        # adding the middle bits to cells
        if s[0] != e[0]
          s[0].to(e[0]) do |x|
            next if x == s[0] || x == e[0]
            cells << { x, s[1], s[2] }
          end
        elsif s[1] != e[1]
          s[1].to(e[1]) do |y|
            next if y == s[1] || y == e[1]
            cells << { s[0], y, s[2] }
          end
        elsif s[2] != e[2]
          s[2].to(e[2]) do |z|
            next if z == s[2] || z == e[2]
            cells << { s[0], s[1], z }
          end
        end
      end
      cells << e
      cells
    end
    bricks
  end

  # settle bricks into a list of {brick, supported bricks, bool meaning resting on ground}
  def settle(bricks)
    # sort bricks by highest z-level so we can pop off bricks with lowest z-level
    bricks = bricks.sort_by do |brick|
      brick.map { |b| b[2] }.min
    end.reverse
    settled = [] of Tuple(Brick, Array(Brick), Bool)
    until bricks.empty?
      brick = bricks.pop
      done = false
      until done
        min_z = brick.map { |b| b[2] }.min
        if min_z == 1 # on ground
          done = true
          next
        end
        # get all parts of the brick that are in its bottom-most edge
        bottom = brick.select { |b| b[2] == min_z }
        # get list of all cells below that list
        below = bottom.map do |b|
          { b[0], b[1], b[2] - 1 }
        end
        # any bricks having parts in that list are supporting this brick
        settled_below = settled.select do |settled_brick, supporting|
          settled_brick.any? { |b| b.in?(below) }
        end
        if settled_below.any?
          # mark supporting bricks as supporting this brick
          settled_below.each do |settled_brick, supporting|
            supporting << brick
          end
          # this brick is supported, can't fall
          done = true
        else
          # lower the brick one z-level
          brick = brick.map do |b|
            { b[0], b[1], b[2] - 1 }
          end
        end
      end
      ground = brick.any? { |b| b[2] == 1 }
      settled << { brick, [] of Brick, ground }
    end
    settled
  end

  def bricks_supporting(bricks, brick)
    bricks.select do |_brick, supporting|
      supporting.includes?(brick)
    end.map do |brick, _supporting|
      brick
    end
  end

  def part1(lines)
    bricks = parse lines
    settled = settle bricks
    # count bricks that are supporting none, or all supported bricks are supported by other bricks
    settled.count do |brick, supporting|
      next true if supporting.none?
      supporting.all? do |supported|
        bricks_supporting(settled, supported).size > 1
      end
    end
  end

  def part2(lines)
    bricks = parse lines
    settled = settle bricks
    # get max z-level for all bricks
    max_z = settled.map { |f_b, f_s| f_b.map { |b| b[2] }.max }.max
    settled.sum do |dis, _supporting|
      debug dis
      falling = [dis]
      2.to(max_z) do |z|
        # get all bricks on this z-level that aren't on the ground
        z_bricks = settled.select do |brick, sup, ground|
          !ground && brick.any? { |b| b[2] == z }
        end
        # for each, consider if is supported by unfallen bricks
        z_bricks.each do |z_brick, _z_brick_supporting, ground|
          next if z_brick.in? falling
          supports = bricks_supporting settled, z_brick
          unfallen_supports = supports - falling
          next if unfallen_supports.any?
          falling << z_brick
        end
      end
      falling.size - 1 # subtract disintegrated
    end
  end
end
