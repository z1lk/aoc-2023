require "../spec_helper"

describe Aoc2023::Nine do
  describe "#part1" do
    it "equals" do
      day(9).example(1).should eq 114
      day(9).real(1).should eq 1834108701
    end
  end
  describe "#part2" do
    it "equals" do
      day(9).example(2).should eq 2
      day(9).real(2).should eq 993
    end
  end
end
