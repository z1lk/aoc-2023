require "../spec_helper"

describe Aoc2023::Eleven do
  describe "#part1" do
    it "equals" do
      day(11).example(1).should eq 374
      day(11).real(1).should eq 9974721
    end
  end
  describe "#part2" do
    it "equals" do
      day(11).real(2).should eq 702770569197
    end
  end
end
