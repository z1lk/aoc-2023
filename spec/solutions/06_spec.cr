require "../spec_helper"

describe Aoc2023::Five do
  describe "#part1" do
    it "equals" do
      day(6).example(1).should eq 288
      day(6).real(1).should eq 608902
    end
  end
  describe "#part2" do
    it "equals" do
      day(6).example(2).should eq 71503
      day(6).real(2).should eq 46173809
    end
  end
end
