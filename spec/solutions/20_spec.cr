require "../spec_helper"

describe Aoc2023::Twenty do
  describe "#part1" do
    it "equals" do
      day(20).example(1).should eq 32000000
      day(20).example(1, 'b').should eq 11687500
      day(20).real(1).should eq 763500168
    end
  end
  describe "#part2" do
    it "equals" do
      day(20).real(2).should eq 207652583562007
    end
  end
end
