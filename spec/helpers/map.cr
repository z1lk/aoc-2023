require "../spec_helper"
#require "../../src/helpers/parsers"

def char_map
  Aoc2023::Parsers.map([
    "ABCDE",
    "FGHIJ",
    "KLMNO",
    "PQRST",
    "UVWXY"
  ])
end

describe Aoc2023::Map do
  context "type char" do
    describe "#init()" do
    end
    describe "#init(map)" do
    end
    describe "#==" do
      it "is true if values are same" do
        m = char_map
        n = char_map
        m.should eq n
        n.set({x: 0, y: 0}, 'Z')
        m.should_not eq n
      end
    end
    describe "#extend_bounds(c)" do
      it "changes bounds min/max" do
        m = char_map

        m.min_x.should eq 0
        m.min_y.should eq 0
        m.extend_bounds({x: -1, y: -1})
        m.min_x.should eq -1
        m.min_y.should eq -1

        m.max_x.should eq 4
        m.max_y.should eq 4
        m.extend_bounds({x: 5, y: 5})
        m.max_x.should eq 5
        m.max_y.should eq 5
      end
    end
    describe "#reset_bounds" do
      it "resets bounds min/max to where values are set" do
        m = char_map

        m.min_x.should eq 0
        m.min_y.should eq 0
        m.extend_bounds({x: -1, y: -1})
        m.min_x.should eq -1
        m.min_y.should eq -1
        m.reset_bounds
        m.min_x.should eq 0
        m.min_y.should eq 0
      end
    end
    describe "#get!(c)" do
      it "returns value if present, else raises error" do
        m = char_map
        m.get!({x: 0, y: 0}).should eq 'A'
        m.unset({x: 0, y: 0}, 'A')
        expect_raises(Exception, "no Char at {x: 0, y: 0}") do
          m.get!({x: 0, y: 0})
        end
        expect_raises(Exception, "no Char at {x: -1, y: -1}") do
          m.get!({x: -1, y: -1})
        end
      end
    end
    describe "#get(c)" do
      it "returns value or nil" do
        m = char_map
        m.get({x: 0, y: 0}).should eq 'A'
        m.unset({x: 0, y: 0}, 'A')
        m.get({x: 0, y: 0}).should be_nil
        m.get({x: -1, y: -1}).should be_nil
      end
    end
    describe "#set(c, t)" do
      it "changes value to t" do
        m = char_map
        m.get({x: 0, y: 0}).should eq 'A'
        m.set({x: 0, y: 0}, 'B')
        m.get({x: 0, y: 0}).should eq 'B'
      end
    end
    describe "#unset(c)" do
      it "removes value" do
        m = char_map
        m.get({x: 0, y: 0}).should eq 'A'
        m.unset({x: 0, y: 0})
        m.get({x: 0, y: 0}).should be_nil
      end
    end
    describe "#fill(t)" do
      it "fills all empty spots with the specified value" do
        m = char_map
        m.unset({x: 0, y: 0})
        m.unset({x: 1, y: 1})
        m.unset({x: 2, y: 2})
        m.unset({x: 3, y: 3})
        m.unset({x: 4, y: 4})
        m.fill('*')
        m.to_s.should eq(
          <<-MAP
            *BCDE
            F*HIJ
            KL*NO
            PQR*T
            UVWX*
            MAP
        )
      end
    end
    describe "#flood(c, t, t2)" do
      it "fills nil adjacent values" do
        m = char_map
        m.unset({x: 0, y: 0})
        m.unset({x: 0, y: 1})
        m.unset({x: 0, y: 2})
        m.unset({x: 1, y: 2})
        m.unset({x: 1, y: 3})
        m.unset({x: 1, y: 4})
        m.unset({x: 2, y: 4})
        m.unset({x: 3, y: 4})
        m.flood({x: 0, y: 0}, '*')
        m.to_s.should eq(
          <<-MAP
            *BCDE
            *GHIJ
            **MNO
            P*RST
            U***Y
            MAP
        )
      end
    end
    describe "#find(t)" do
      it "finds first value" do
        m = char_map
        m.find('G').should eq({x: 1, y: 1})
        m.set({x: 2, y: 2}, 'G')
        m.find('G').should eq({x: 1, y: 1})
      end
    end
    describe "#find_all(t)" do
      it "finds all values" do
        m = char_map
        m.find_all('G').should eq([ {x: 1, y: 1} ])
        m.set({x: 2, y: 2}, 'G')
        m.find_all('G').should eq([ {x: 1, y: 1}, {x: 2, y: 2} ])
      end
    end
    describe "#all_x" do
    end
    describe "#all_y" do
    end
    describe "#add(a,b)" do
      it "adds coords" do
        m = char_map
        m.add({x: 1, y: 2}, {x: 2, y: 3}).should eq({ x: 3, y: 5 })
      end
    end
    describe "#diff(a,b)" do
      it "diffs coords" do
        m = char_map
        m.diff({x: 3, y: 5}, {x: 2, y: 3}).should eq({ x: 1, y: 2 })
      end
    end
    describe "#adjacent?(a,b)" do
      it "is true if coords are diagonally adjacent" do
        m = char_map
        m.adjacent?({x: 1, y: 1}, {x: 1, y: 1}).should be_false
        m.adjacent?({x: 1, y: 1}, {x: 1, y: 2}).should be_true
        m.adjacent?({x: 1, y: 1}, {x: 1, y: 3}).should be_false
      end
    end
    describe "#diagonal?(a,b)" do
      it "is true if coords are diagonally adjacent" do
        m = char_map
        m.diagonal?({x: 1, y: 1}, {x: 2, y: 1}).should be_false
        m.diagonal?({x: 1, y: 1}, {x: 2, y: 2}).should be_true
        m.diagonal?({x: 1, y: 1}, {x: 2, y: 3}).should be_false
      end
    end
    describe "#neighbors(c)" do
      it "returns neighboring values" do
        m = char_map
        n = m.neighbors({x: 1, y: 1})
        n.size.should eq 4
        n.should contain({ {x: 1, y: 0}, 'B'})
        n.should contain({ {x: 0, y: 1}, 'F'})
        n.should contain({ {x: 2, y: 1}, 'H'})
        n.should contain({ {x: 1, y: 2}, 'L'})
      end
      it "can return diagonally neighboring values" do
        m = char_map
        n = m.neighbors({x: 1, y: 1}, true)
        n.size.should eq 8
        n.should contain({ {x: 0, y: 0}, 'A'})
        n.should contain({ {x: 1, y: 0}, 'B'})
        n.should contain({ {x: 2, y: 0}, 'C'})
        n.should contain({ {x: 0, y: 1}, 'F'})
        n.should contain({ {x: 2, y: 1}, 'H'})
        n.should contain({ {x: 0, y: 2}, 'K'})
        n.should contain({ {x: 1, y: 2}, 'L'})
        n.should contain({ {x: 2, y: 2}, 'M'})
      end
    end
    describe "#dist(a,b)" do
      it "computes taxicab distance" do
        m = char_map
        m.dist({x: 1, y: 2}, {x: 4, y: 3}).should eq 4
      end
    end
  end

  context "type array of char" do
  end
end
