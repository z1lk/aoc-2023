require "../spec_helper"

describe Aoc2023::Three do
  describe "#part1" do
    it "equals" do
      day(3).example(1).should eq 4361
      day(3).real(1).should eq 520019
    end
  end
  describe "#part2" do
    it "equals" do
      day(3).example(2).should eq 467835
      day(3).real(2).should eq 75519888
    end
  end
end
