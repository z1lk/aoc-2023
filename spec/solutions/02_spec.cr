require "../spec_helper"

describe Aoc2023::One do
  describe "#part1" do
    it "equals" do
      s2.part1(s2.example_input).should eq 8
      s2.part1(s2.real_input).should eq 2545
    end
  end
  describe "#part2" do
    it "equals" do
      s2.part2(s2.example_input).should eq 2286
      s2.part2(s2.real_input).should eq 78111
    end
  end
end
