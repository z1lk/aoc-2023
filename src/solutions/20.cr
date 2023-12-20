class Aoc2023::Twenty < Aoc2023::Solution
  enum Pulse
    Low     # 0
    High    # 1
    Connect # 2
  end

  class Queue
    getter queue : Array(Tuple(String, String, Pulse))
    getter low_count : Int128, high_count : Int128
    def initialize
      @queue = [] of Tuple(String, String, Pulse)
      @low_count = 0_i128
      @high_count = 0_i128
    end
    def empty?
      @queue.empty?
    end
    def shift
      @queue.shift
    end
    def add(item)
      @low_count += 1 if item[2] == Pulse::Low
      @high_count += 1 if item[2] == Pulse::High
      @queue << item
    end
    def reset!
      @low_count = 0_i128
      @high_count = 0_i128
    end
  end

  abstract class Module
    getter name : String, dests : Array(String), queue : Queue
    def initialize(@name, @dests, @queue)
      @connected = false
    end
    abstract def receive(sender : String, pulse : Pulse)
    def send(dest : String, pulse : Pulse)
      item = { dest, name, pulse }
      pulse_type = case pulse
                   when Pulse::Low then "low"
                   when Pulse::High then "high"
                   when Pulse::Connect then "connect"
                   else "unrecognized pulse type"
                   end
      #debug "#{name} -#{pulse_type}-> #{dest}"
      queue.add item
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
        if @on
          send_all Pulse::High
        else
          send_all Pulse::Low
        end
      when Pulse::High
        # nothing
      end
    end
  end 

  class Conjunction < Module
    def initialize(@name, @dests, @queue)
      @mem = Hash(String, Pulse).new # sender, bool
      super
    end
    def receive(sender, pulse)
      # initialization
      if pulse == Pulse::Connect
        @mem[sender] = Pulse::Low
        connect
        return
      end

      @mem[sender] = pulse
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
        when '%'
          FlipFlop
        when '&'
          Conjunction
        else
          case name
          when "broadcaster"
            Broadcaster
          when "button"
            Button
          else raise "unprefixed non-broadcaster non-button" 
          end
        end
      klass.new(name, dests, queue)
    end
    outputs = modules.flat_map { |m| m.dests }.sort.uniq.select { |d| !modules.find { |m| m.name == d } }
    outputs.each do |output|
      modules << Output.new(output, queue)
    end
    modules
  end

  def press(modules)
    #debug "", "---"
    button = modules[0]
    raise "no button" unless button.is_a?(Button)
    button.press
    process modules
  end

  def process(modules)
    button = modules[0]
    raise "no button" unless button.is_a?(Button)
    queue = button.queue
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
    modules = parse lines
    button = modules[0]
    button.connect
    process modules

    1000.times do
      press modules
    end
    queue = button.queue
    queue.low_count * queue.high_count
  end

  def part2(lines)
    modules = parse lines
    button = modules[0]
    button.connect
    process modules

    rx = modules.find { |m| m.name == "rx" }
    raise "no rx" unless rx.is_a?(Output)
    i = 0_i128
    until rx.low_count > 0
      if i % 100_000 == 0
        debug "---"
        debug i
        debug_line "low", rx.low_count
        debug_line "high" ,rx.high_count
      end
      i += 1
      press modules
    end
    i
  end
end
