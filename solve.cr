require "./src/aoc2023"
require "option_parser"
require "benchmark"

day = -1
part = 1
input_type = :real
input_ver = nil

ENV["DEBUG"] = "false"

OptionParser.parse do |parser|
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.on("-d DAY", "--day DAY", "Day 1-25") do |d|
    day = d.to_i
  end
  parser.on("-p PART", "--part PART", "Part 1 or 2 (default 1)") do |p|
    part = p.to_i
  end
  parser.on("-t", "--test", "Use the day's test input") do
    input_type = :test
  end
  parser.on("-e", "--example", "Use the day's example input") do
    input_type = :example
  end
  parser.on("-v VERSION", "--version VERSION", "Use a different version of the day's input (e.g. 01b)") do |ver|
    input_ver = ver
  end
  parser.on("-D", "--debug", "Print debug lines") do
    ENV["DEBUG"] = "true"
  end
  #parser.on("-i INPUT", "--input INPUT", "Specify the input filename directly") do |ver|
  #  input_type = :filename
  #  input_ver = ver
  #end
end

if day == -1
  t = Time.local Time::Location.load("America/New_York")
  if t.year == 2023 && t.month == 12 && t.day <= 25
    day = t.day
  end
end

if day == -1
  STDERR.puts "Day must be specified with `-d DAY`"
  exit(1)
end

solution = day(day)
header = [
  "[Day #{day}]",
  "[Part #{part}]",
  "[Input type \"#{input_type}\"]"
]
if input_ver.nil?
  header << "[Input version \"#{input_ver}\"]"
end
puts header.join(" "), ""
bm = Benchmark.realtime do
  puts solution.solve(part, input_type, input_ver)
end
puts "", "solved in #{bm}"
