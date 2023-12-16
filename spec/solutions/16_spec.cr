require "../spec_helper"

describe Aoc2023::Sixteen do
  describe "#part1" do
    it "equals" do
      day(16).example(1).should eq 46
      day(16).real(1).should eq 7074
    end
  end
  describe "#part2" do
    it "equals" do
      day(16).example(2).should eq 51
      #day(16).real(2).should eq 7530
    end
  end
end
