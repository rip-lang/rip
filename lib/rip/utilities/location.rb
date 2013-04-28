module Rip::Utilities
  class Location
    attr_reader :origin
    attr_reader :offset
    attr_reader :line
    attr_reader :column

    def initialize(origin, offset, line, column)
      @origin = origin
      @offset = offset
      @line = line
      @column = column
    end

    def ==(other)
      (origin == other.origin) &&
        (offset == other.offset)
    end

    def add_character(count = 1)
      self.class.new(origin, offset + count, line, column + count)
    end

    def add_line(count = 1)
      self.class.new(origin, offset + count, line + count, 1)
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def to_s
      "#{origin}:#{to_debug}"
    end

    def to_debug
      "#{line}:#{column}(#{offset})"
    end
  end
end
