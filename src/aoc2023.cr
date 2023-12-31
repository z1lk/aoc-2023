def debug_off
  yield if false
end

def debug
  yield if debug?
end

def debug?
  ENV.has_key?("DEBUG") && ENV["DEBUG"] != "false"
end

def debug_line(*args, sep = '/', indent = 0)
  debug " " * indent + args.join " #{sep} "
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

require "./solution.cr"

module Aoc2023
  VERSION = "0.1.0"

  DAYS = [
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
    "Twenty",
    "TwentyOne",
    "TwentyTwo",
    "TwentyThree",
    "TwentyFour",
    "TwentyFive"
  ]
end

require "./solution"
require "./solutions/*"
require "./helpers/*"

def day_class(i, variant = nil)
  days = Aoc2023::Solution.all.select { |s| s.day_int_padded == i.to_s.rjust(2, '0') }
  if variant
    days.find { |s| s.variant == variant } 
  else
    days.first
  end
end

def day(i, variant = nil)
  klass = day_class(i, variant)
  raise "day \"#{i}\" (variant \"#{variant}\") not found" unless klass
  klass.new
end
