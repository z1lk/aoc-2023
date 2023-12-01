require "../spec_helper"

describe Aoc2023::One do
  describe "#part1" do
    it "equals" do
      s1.part1(s1.example_input).should eq 142
      s1.part1(s1.real_input).should eq 54601
    end
  end
  describe "#part2" do
    it "equals" do
      s1.part2(s1.example_input("01b")).should eq 281
      s1.part2(s1.real_input).should eq 54078
    end
  end
end
