require "../spec_helper"

describe Aoc2023::TwentyFour do
  describe "#part1" do
    it "equals" do
      day(24).example(1).should eq 2
      day(24).real(1).should eq 21785
    end
  end
  describe "#part2" do
    it "equals" do
      #day(24).example(2).should eq 154
      # day(24).real(2).should eq 6554
    end
  end
end
