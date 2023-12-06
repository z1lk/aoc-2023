require "../spec_helper"

describe Aoc2023::One do
  describe "#part1" do
    it "equals" do
      day(1).example(1).should eq 142
      day(1).real(1).should eq 54601
      day(1).test(1).should eq 143
      day(1).test(1, 'b').should eq 144
    end
  end
  describe "#part2" do
    it "equals" do
      day(1).example(2, 'b').should eq 281
      day(1).real(2).should eq 54078
    end
  end
end
