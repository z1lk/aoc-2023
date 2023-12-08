require "../spec_helper"

describe Aoc2023::Eight do
  describe "#part1" do
    it "equals" do
      day(8).example(1).should eq 2
      day(8).example(1, 'b').should eq 6
      day(8).real(1).should eq 17873
    end
  end
  describe "#part2" do
    it "equals" do
      day(8).example(2, 'c').should eq 6
      day(8).real(2).should eq 15746133679061
    end
  end
end
