require "../spec_helper"

describe Aoc2023::Twelve do
  describe "#part1" do
    it "equals" do
      day(12).example(1).should eq 21
      day(12).real(1).should eq 7236
    end
  end
  describe "#part2" do
    it "equals" do
      day(12).example(2).should eq 525152
      day(12).real(2).should eq 11607695322318
    end
  end
end
