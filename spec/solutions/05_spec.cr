require "../spec_helper"

describe Aoc2023::Five do
  describe "#part1" do
    it "equals" do
      s5.part1(s5.example_input).should eq 35
      s5.part1(s5.real_input).should eq 331445006
    end
  end
  describe "#part2" do
    it "equals" do
      s5.part2(s5.example_input).should eq 46
      s5.part2(s5.real_input).should eq 6472060
    end
  end
end
