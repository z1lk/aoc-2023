require "../spec_helper"

describe Aoc2023::Thirteen do
  describe "#part1" do
    it "equals" do
      day(13).example(1).should eq 405
      day(13).real(1).should eq 31265
    end
  end
  describe "#part2" do
    it "equals" do
      day(13).example(2).should eq 400
      day(13).real(2).should eq 39359
    end
  end
end
