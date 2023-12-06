require "../spec_helper"

describe Aoc2023::Four do
  describe "#part1" do
    it "equals" do
      day(4).example(1).should eq 13
      day(4).real(1).should eq 27059
    end
  end
  describe "#part2" do
    it "equals" do
      day(4).example(2).should eq 30
      day(4).real(2).should eq 5744979
    end
  end
end
