require "../spec_helper"

describe Aoc2023::Four do
  describe "#part1" do
    it "equals" do
      s4.part1(s4.example_input).should eq 13
      s4.part1(s4.real_input).should eq 27059
    end
  end
  describe "#part2" do
    it "equals" do
      s4.part2(s4.example_input).should eq 30
      s4.part2(s4.real_input).should eq 5744979
    end
  end
end
