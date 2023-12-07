class Aoc2023::Seven < Aoc2023::Solution
  CARDS = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']

  def parse(lines)
    Parsers.pattern(lines, /(\w+) (\d+)/) do |m|
      {m[1].chars, m[2].to_i32}
    end
  end

  def part1(lines)
    hands = parse lines
    hands = sort hands, wild: false
    winnings hands
  end

  def part2(lines)
    hands = parse lines
    hands = sort hands, wild: true
    winnings hands
  end

  def sort(hands, wild = false)
    hands.sort do |(x, _x_bid), (y, _y_bid)|
      x_st = hand_st(x, wild)
      y_st = hand_st(y, wild)
      next x_st <=> y_st if x_st != y_st
      x_card_st = y_card_st = 0
      5.times do |i|
        x_card_st = card_st(x[i], wild)
        y_card_st = card_st(y[i], wild)
        break if x_card_st != y_card_st
      end
      x_card_st <=> y_card_st
    end
  end

  def hand_st(hand, wild)
    wild ? hand_st_wild(hand) : hand_st_no_wild(hand)
  end

  def card_st(card, wild)
    wild ? card_st_wild(card) : card_st_no_wild(card)
  end

  def hand_st_no_wild(hand)
    n = CARDS.map { |c| hand.count(c) }
    case
    when n.includes?(5) then 0
    when n.includes?(4) then 1
    when n.includes?(3) && n.includes?(2) then 2
    when n.includes?(3) && n.count(1) == 2 then 3
    when n.count(2) == 2 && n.includes?(1) then 4
    when n.includes?(2) && n.count(1) == 3 then 5
    when n.count(1) == 5 then 6
    else raise "unknown hand type for #{hand}"
    end
  end

  def hand_st_wild(hand)
    return hand_st_no_wild(hand) if hand.count('J') == 0
    # replace J with every card and find the stongest hand
    CARDS.map do |c|
      replaced = hand.map { |d| d == 'J' ? c : d }
      hand_st_no_wild replaced
    end.min
  end

  def card_st_no_wild(c)
    CARDS.index!(c)
  end

  def card_st_wild(c)
    return card_st_no_wild(c) if c != 'J'
    CARDS.size # J weaker than all
  end

  def winnings(hands)
    hands.map_with_index do |(cards, bid), i|
      (hands.size - i) * bid
    end.sum
  end
end
