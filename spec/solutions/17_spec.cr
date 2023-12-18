require "../spec_helper"

describe Aoc2023::Seventeen do
  describe "#part1" do
    it "equals" do
      day(17).example(1).should eq 102
      #day(17).real(1).should eq 956
    end
  end
  describe "#part2" do
    it "equals" do
      day(17).example(2).should eq 94
      day(17).example(2, 'b').should eq 71
      #day(17).real(2).should eq 1106
    end
  end
end
