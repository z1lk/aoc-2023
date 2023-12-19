require "../spec_helper"

describe Aoc2023::Eighteen do
  describe "#part1" do
    it "equals" do
      day(18).example(1).should eq 62
      day(18).real(1).should eq 70253
    end
  end
  describe "#part2" do
    it "equals" do
      day(18).example(2).should eq 952408144115
      # solved in 01:09:51.135018367
      #day(18).real(2).should eq 131265059885080
    end
  end
end
