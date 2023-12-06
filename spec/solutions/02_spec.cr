require "../spec_helper"

describe Aoc2023::Two do
  describe "#part1" do
    it "equals" do
      day(2).example(1).should eq 8
      day(2).real(1).should eq 2545
    end
  end
  describe "#part2" do
    it "equals" do
      day(2).example(2).should eq 2286
      day(2).real(2).should eq 78111
    end
  end
end
