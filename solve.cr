require "./src/aoc2023"
require "option_parser"
require "benchmark"

ENV["DEBUG"] = "true"

day_flag = -1
part = 1
input_type = :real
input_ver = ""

OptionParser.parse do |parser|
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.on("-d DAY", "--day DAY", "Day 1-25") do |d|
    day_flag = d
  end
  parser.on("-p PART", "--part PART", "Part 1 or 2 (default 1)") do |p|
    part = p.to_i
  end
  parser.on("-t", "--test", "Use the day's test input") do |ver|
    input_type = :test
  end
  parser.on("-e", "--example", "Use the day's example input") do |ver|
    input_type = :example
  end
  parser.on("-v VERSION", "--version VERSION", "Use a different version of the day's input (e.g. 01b)") do |ver|
    input_ver = ver
  end
  parser.on("-i INPUT", "--input INPUT", "Specify the input filename directly") do |ver|
    input_type = :filename
    input_ver = ver
  end
end

t = Time.local
if day_flag == -1 && t.year == 2023 && t.month == 12 && t.day <= 25
  day_flag = t.day
end

if day_flag == -1
  STDERR.puts "Day must be specified with `-d DAY`"
  exit(1)
end

solution = day(day_flag)
header = [
  "[Day #{day_flag}]",
  "[Part #{part}]",
  "[Input type \"#{input_type}\"]"
]
if input_ver != ""
  header << "[Input version \"#{input_ver}\"]"
end
puts header.join(" "), ""
bm = Benchmark.realtime do
  puts solution.solve(part, input_type, input_ver)
end
puts "", "solved in #{bm}"
