require "../spec_helper"

describe Aoc2023::Nineteen do
  describe "#part1" do
    it "equals" do
      day(19).example(1).should eq 19114
      day(19).real(1).should eq 489392
    end
  end
  describe "#part2" do
    it "equals" do
      day(19).example(2).should eq 167409079868000
      # solved in 00:27:32.658939448
      # day(19).real(2).should eq 134370637448305
    end
  end
end
