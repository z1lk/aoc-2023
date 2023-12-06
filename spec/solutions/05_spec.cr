require "../spec_helper"

describe Aoc2023::Five do
  describe "#part1" do
    it "equals" do
      day(5).example(1).should eq 35
      day(5).real(1).should eq 331445006
    end
  end
  describe "#part2" do
    it "equals" do
      day(5).example(2).should eq 46
      day(5).real(2).should eq 6472060
    end
  end
end
