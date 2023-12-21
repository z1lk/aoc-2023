class Aoc2023::Twenty < Aoc2023::Solution
  enum Pulse
    Low
    High
    Connect # we hijack pulse sending with our own connect signal so modules can tell what their inputs are
  end

  # pulse queue wrapper for array that tracks button presses, pulse counts, and logs
  class Queue
    getter queue : Array(Tuple(String, String, Pulse))
    getter low_count : Int128, high_count : Int128, presses : Int128, tick : Int128
    def initialize
      @queue = [] of Tuple(String, String, Pulse)
      @low_count = 0_i128
      @high_count = 0_i128
      @presses = 0_i128
      @tick = 0_i128
    end
    def empty?
      @queue.empty?
    end
    def shift
      @tick += 1
      @queue.shift
    end
    def add(item)
      dest, sender, pulse = item
      # button only sends one pulse to broadcaster so this is ok, otherwise we'd count a press for every dest
      if sender == "button"
        @presses += 1
        reset_tick!
      end
      debug_off do
        pulse_type = case pulse
                     when Pulse::Low then "low"
                     when Pulse::High then "high"
                     when Pulse::Connect then "connect"
                     else "unrecognized pulse type"
                     end
        debug "@#{@presses} #{sender} -#{pulse_type}-> #{dest}"
      end
      @low_count += 1 if item[2] == Pulse::Low
      @high_count += 1 if item[2] == Pulse::High
      @queue << item
    end
    def reset!
      @low_count = 0_i128
      @high_count = 0_i128
      @presses = 0_i128
      @tick = 0_i128
    end
    def reset_tick!
      @tick = 0_i128
    end
  end

  abstract class Module
    getter name : String, dests : Array(String), queue : Queue
    def initialize(@name, @dests, @queue)
      @connected = false
    end
    abstract def receive(sender : String, pulse : Pulse)
    def send(dest : String, pulse : Pulse)
      queue.add({ dest, name, pulse })
    end
    def send_all(pulse : Pulse)
      dests.each do |dest|
        send dest, pulse
      end
    end
    def connect
      return if @connected
      @connected = true
      send_all Pulse::Connect
      true
    end
  end

  class FlipFlop < Module
    def initialize(@name, @dests, @queue)
      @on = false
      super
    end
    def receive(sender, pulse)
      case pulse
      when Pulse::Connect
        connect
      when Pulse::Low
        @on = !@on
        send_all @on ? Pulse::High : Pulse::Low
      when Pulse::High
        # nothing
      end
    end
  end 

  class Conjunction < Module
    getter hist
    def initialize(@name, @dests, @queue)
      # sender => { pulse => arr ( pulse, queue, tick ) }
      @hist = Hash(String, Array(Tuple(Pulse, Int128, Int128))).new
      @mem = Hash(String, Pulse).new
      super
    end
    def receive(sender, pulse)
      # initialization
      if pulse == Pulse::Connect
        @mem[sender] = Pulse::Low
        @hist[sender] = [] of Tuple(Pulse, Int128, Int128)
        connect
        return
      end
      @mem[sender] = pulse
      @hist[sender] << { pulse, queue.presses, queue.tick }
      if @mem.values.all?(Pulse::High)
        send_all Pulse::Low
      else
        send_all Pulse::High
      end
    end
  end

  class Broadcaster < Module
    def receive(sender, pulse)
      if pulse == Pulse::Connect
        connect
        return 
      end

      send_all pulse
    end
  end

  class Button < Module
    def receive(sender, pulse)
      raise "button shouldn't receive anything"
    end
    def press
      send_all Pulse::Low
    end
  end

  class Output < Module
    getter low_count : Int128, high_count : Int128
    def self.new(name, queue)
      new(name, [] of String, queue)
    end
    def initialize(@name, @dests, @queue)
      @low_count = 0_i128
      @high_count = 0_i128
      super
    end
    def receive(sender, pulse)
      #debug "output received #{pulse} from #{sender}"
      @low_count += 1 if pulse == Pulse::Low
      @high_count += 1 if pulse == Pulse::High
    end
  end

  def parse(lines)
    queue = Queue.new
    lines.unshift "button -> broadcaster"
    modules = lines.map do |line|
      name, dest = line.split(" -> ")
      if name[0].in? ['&','%']
        prefix = name[0]
        name = name[1..-1]
      end
      dests = dest.split(", ")
      klass =
        case prefix
        when '%' then FlipFlop
        when '&' then Conjunction
        else
          case name
          when "broadcaster" then Broadcaster
          when "button" then Button
          else raise "unprefixed non-broadcaster non-button" 
          end
        end
      klass.new(name, dests, queue)
    end
    # ouputs are the destination modules in entries, that don't have their own line
    outputs = modules.flat_map { |m| m.dests }.sort.uniq.select { |d| !modules.find { |m| m.name == d } }
    outputs.each do |output|
      modules << Output.new(output, queue)
    end
    { queue, modules }
  end

  def press(modules, queue)
    button = modules[0]
    raise "no button" unless button.is_a?(Button)
    button.press
    process modules, queue
  end

  def connect(modules, queue)
    button = modules[0]
    button.connect
    process modules, queue
    queue.reset!
  end

  def process(modules, queue)
    until queue.empty?
      name, sender, pulse = queue.shift
      mod = modules.find { |m| m.name == name }
      if !mod
        raise "couldn't find module #{name}"
      end
      mod.receive sender, pulse
    end
  end

  def part1(lines)
    queue, modules = parse lines
    connect modules, queue
    1000.times do
      press modules, queue
    end
    queue.low_count * queue.high_count
  end

  def part2(lines)
    queue, modules = parse lines
    connect modules, queue

    # 4 modules feed into conjunction dh which feeds to rx.
    # &nh -> dh
    # &dr -> dh
    # &xm -> dh
    # &tr -> dh
    # &dh -> rx
    # so to find when dh sends a low pulse to rx, we need to find when it receives a high pulse from each of its inputs.
    dh = modules.find { |m| m.name == "dh" }
    rx = modules.find { |m| m.name == "rx" }
    raise "dh is not conjunction" unless dh.is_a?(Conjunction)
    # loop until dh has received a high pulse from all modules at least three times
    loop do
      break if dh.hist.values.all? { |e| e.select { |v| v[0] == Pulse::High }.size > 2 }
      press modules, queue
    end

    # the highs repeat regularly, so we can just find the LCM of each module's first high sent do dh
    highs = dh.hist.map do |sender, hist|
      # hist is {pulse, queue, tick}, [1] is the queue press count
      hist.find! { |h| h[0] == Pulse::High }[1]
    end
    highs.reduce(1_i128) { |m, n| m.lcm(n) }

    # everything below was for analysis but not necessary for calculating solution
    #ranges = Hash(
    #  String,
    #  Array(
    #    Tuple(
    #      Pulse,
    #      Tuple(Int128, Int128), # start (queue, tick)
    #      Tuple(Int128, Int128)  # end   (queue, tick)
    #    )
    #  )
    #).new
    #dh.hist.each do |sender, sender_hist|
    #  #debug "sender #{sender}"
    #  ranges[sender] = [] of Tuple(Pulse, Tuple(Int128, Int128), Tuple(Int128, Int128))
    #  sender_hist.each do |hist| # {pulse, queue, tick}
    #    #next unless hist[0] == Pulse::High
    #    last =
    #      if ranges[sender].empty?
    #        # fake last with starting state
    #        { Pulse::High, { 0_i128, 0_i128 }, { 0_i128, 0_i128 } }
    #      else
    #        ranges[sender].last
    #      end
    #    last_pulse, last_start, last_end = last
    #    hist_pulse, hist_queue, hist_tick = hist
    #    cur_pulse = last_pulse == Pulse::High ? Pulse::Low : Pulse::High
    #    if cur_pulse != hist_pulse
    #      ranges[sender] << ({
    #        cur_pulse,
    #        last_end,
    #        { hist_queue, hist_tick }
    #      })
    #    end
    #  end
    #end
    #debug ranges
    #highs = ranges.map do |sender, sender_ranges|
    #  high1 = sender_ranges.select { |r| r[0] == Pulse::High }[0][1][0]
    #  high2 = sender_ranges.select { |r| r[0] == Pulse::High }[1][1][0]
    #  { high1, high2 - high1 }
    #end
  end

  #def part2_brute(lines)
  #  modules = parse lines
  #  button = modules[0]
  #  button.connect
  #  process modules
  #  rx = modules.find { |m| m.name == "rx" }
  #  raise "no rx" unless rx.is_a?(Output)
  #  i = 0_i128
  #  until rx.low_count > 0
  #    if i % 100_000 == 0
  #      debug "---"
  #      debug i
  #      debug_line "low", rx.low_count
  #      debug_line "high" ,rx.high_count
  #    end
  #    i += 1
  #    press modules
  #  end
  #  i
  #end
end
