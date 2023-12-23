require "../spec_helper"

describe Aoc2023::TwentyThree do
  describe "#part1" do
    it "equals" do
      day(23).example(1).should eq 94
      day(23).real(1).should eq 2394
    end
  end
  describe "#part2" do
    it "equals" do
      day(23).example(2).should eq 154
      # solved in 00:00:27.849699471 (release build)
      # day(23).real(2).should eq 6554
    end
  end
end
