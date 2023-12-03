require "../spec_helper"

describe Aoc2023::Three do
  describe "#part1" do
    it "equals" do
      s3.part1(s3.example_input).should eq 4361
      s3.part1(s3.real_input).should eq 520019
    end
  end
  describe "#part2" do
    it "equals" do
      s3.part2(s3.example_input).should eq 467835
      s3.part2(s3.real_input).should eq 75519888
    end
  end
end
