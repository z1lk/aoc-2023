require "../spec_helper"

describe Aoc2023::Fourteen do
  describe "#part1" do
    it "equals" do
      day(14).example(1).should eq 136
      day(14).real(1).should eq 108826
    end
  end
  describe "#part2" do
    it "equals" do
      day(14).example(2).should eq 64
      # slow
      # day(14).real(2).should eq 99291
    end
  end
end
