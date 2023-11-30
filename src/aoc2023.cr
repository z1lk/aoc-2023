def debug?
  ENV.has_key?("DEBUG") && ENV["DEBUG"]
end

def debug(*args)
  puts *args if debug?
end

def debug_pp(arg)
  pp arg if debug?
end

def debug_buffered(arg, print = false)
  STDOUT.sync = false
  STDOUT.flush_on_newline = false
  if print
    return if arg.nil?
    arg = arg.to_s if arg.is_a?(Char)
    STDOUT.printf(arg)
  else
    STDOUT.puts(arg)
  end
end

def debug_flush
  STDOUT.flush
  STDOUT.sync = true
  STDOUT.flush_on_newline = true
end

def debug_i(*args) # interactive
  return unless debug?
  puts *args
  gets
end

module Aoc2023
  VERSION = "0.1.0"

  DAYS = {
    "One" => "01",
    "Two" => "02",
    "Three" => "03",
    "Four" => "04",
    "Five" => "05",
    "Six" => "06",
    "Seven" => "07",
    "Eight" => "08",
    "Nine" => "09",
    "Ten" => "10",
    "Eleven" => "11",
    "Twelve" => "12",
    "Thirteen" => "13",
    "Fourteen" => "14",
    "Fifteen" => "15",
    "Sixteen" => "16",
    "Seventeen" => "17",
    "Eighteen" => "18",
    "Nineteen" => "19",
    "Twenty" => "20",
    "TwentyOne" => "21",
    "TwentyTwo" => "22",
    "TwentyThree" => "23",
    "TwentyFour" => "24",
    "TwentyFive" => "25"
  }

end

require "./solution"
require "./solutions/*"
require "./helpers/*"
