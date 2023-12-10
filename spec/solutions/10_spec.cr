require "../spec_helper"

describe Aoc2023::Ten do
  describe "#part1" do
    it "equals" do
      day(10).example(1).should eq 4
      day(10).example(1, 'b').should eq 8
      day(10).real(1).should eq 6682
    end
  end
  describe "#part2" do
    it "equals" do
      day(10).example(2, 'c').should eq 4
      day(10).example(2, "c-squeeze").should eq 4
      day(10).example(2, 'd').should eq 8
      day(10).example(2, 'e').should eq 10
      day(10).real(2).should eq 353
    end
  end
end
