class Aoc2023::Fifteen < Aoc2023::Solution
  def part1(lines)
    steps = lines[0].split(",")
    steps.sum do |step|
      hash step
    end
  end

  def part2(lines)
    steps = lines[0].split(",")
    boxes = Array(
      Array(Tuple(String, Int32))
    ).new(256) do
      Array(Tuple(String, Int32)).new
    end

    steps.each do |step|
      if step.matches?(/=/)
        label, focal_len = step.split "="
        focal_len = focal_len.to_i
        box = boxes[ hash(label) ]
        lens = { label, focal_len }
        if i = box.index { |(lab, len)| lab == label }
          box[i] = lens
        else
          box << lens
        end
      else
        label = step[0...-1]
        box = boxes[ hash(label) ]
        box.reject! { |(lab, len)| lab == label }
      end
    end

    boxes.each.with_index.sum do |box, box_i|
      box.each.with_index.sum do |(lab, len), lens_i|
        (box_i + 1) * (lens_i + 1) * len
      end
    end
  end

  def hash(str)
    str.chars.reduce(0) do |val, char|
      val += char.ord
      val *= 17
      val = val % 256
    end
  end
end
