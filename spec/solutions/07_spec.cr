require "../spec_helper"

describe Aoc2023::Seven do
  describe "#part1" do
    it "equals" do
      day(7).example(1).should eq 6440
      day(7).real(1).should eq 251136060
    end
  end
  describe "#part2" do
    it "equals" do
      day(7).example(2).should eq 5905
      day(7).real(2).should eq 249400220
    end
  end
end
