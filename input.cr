require "./src/aoc2023"
require "dotenv"
Dotenv.load
require "option_parser"
require "http/client"
require "http/headers"
require "xml"

day = -1
example = false
OptionParser.parse do |parser|
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.on("-d DAY", "--day DAY", "Day 1-25") do |d|
    day = d
  end
  parser.on("-e", "--example", "Download the example input") do
    example = true
  end
end

t = Time.local
if day == -1 && t.year == 2023 && t.month == 12 && t.day <= 25
  day = t.day
end

if day == -1
  STDERR.puts "Day must be specified with `-d DAY`"
  exit(1)
end

if !ENV.has_key?("AOC_SESSION_COOKIE")
  STDERR.puts "Set AOC_SESSION_COOKIE in ENV"
  exit(1)
end

input =
  if !STDIN.tty?
    STDIN.gets_to_end
  else
    if example
      STDERR.puts "Can't download example from web, use STDIN"
      exit(1)
    end
    session = ENV["AOC_SESSION_COOKIE"]
    headers = HTTP::Headers.new
    headers["Cookie"] = "session=#{session}"
    url = "https://adventofcode.com/2023/day/#{day}/input"
    response = HTTP::Client.get url, headers
    unless response.success?
      STDERR.puts "Something is wrong. Received a non-success response from #{url}"
      exit(1)
    end
    response.body
  end

path = "inputs/"
path += "example/" if example
path += day.to_s.rjust(2, '0')

File.write path, input
STDOUT.puts "Successfully wrote input to #{path}"
