require "benchmark"
require "./src/aoc2023"

ENV["DEBUG"] = "true"

day_flag = -1
part = 1
input_type = :real

require "option_parser"
OptionParser.parse do |parser|
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.on("-d DAY", "--day DAY", "Day 1-25") do |d|
    day_flag = d
  end
  parser.on("-p PART", "--part PART", "Part 1 or 2") do |p|
    part = p.to_i
  end
  parser.on("-t", "--test", "Use the test input for the day") do
    input_type = :test
  end
  parser.on("-e", "--example", "Use the example input for the day") do
    input_type = :example
  end
  parser.on("-i INPUT", "--input INPUT", "Specify the input filename directly") do |str|
    input_type = str
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
puts "[Day #{day_flag}] [Part #{part}] [Input \"#{input_type}\"]", ""
bm = Benchmark.realtime do
  puts solution.solve(part, input_type)
end
puts "\n(#{bm})"
