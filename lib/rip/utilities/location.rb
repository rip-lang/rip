module Rip::Utilities
  class Location
    attr_reader :origin
    attr_reader :absolute_position
    attr_reader :line
    attr_reader :position

    def initialize(origin, absolute_position, line, position)
      @origin = origin
      @absolute_position = absolute_position
      @line = line
      @position = position
    end

    def ==(other)
      (origin == other.origin) &&
        (absolute_position == other.absolute_position)
    end

    def add_character(count = 1)
      self.class.new(origin, absolute_position + count, line, position + count)
    end

    def add_line(count = 1)
      self.class.new(origin, absolute_position, line + count, position).add_character(count)
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def to_s
      "#{origin}:#{line}:#{position}(#{absolute_position})"
    end
  end
end
