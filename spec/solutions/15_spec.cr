require "../spec_helper"

describe Aoc2023::Fifteen do
  describe "#part1" do
    it "equals" do
      day(15).example(1).should eq 1320
      day(15).real(1).should eq 511215
    end
  end
  describe "#part2" do
    it "equals" do
      day(15).example(2).should eq 145
      day(15).real(2).should eq 236057
    end
  end
end
