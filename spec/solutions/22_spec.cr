require "../spec_helper"

describe Aoc2023::TwentyTwo do
  describe "#part1" do
    it "equals" do
      day(22).example(1).should eq 5
      day(22).real(1).should eq 407
    end
  end
  describe "#part2" do
    it "equals" do
      day(22).example(2).should eq 7
      # solved in 00:00:34.053970416
      # day(22).real(2).should eq 59266
    end
  end
end
