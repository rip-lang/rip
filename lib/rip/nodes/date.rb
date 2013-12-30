module Rip::Nodes
  class Date < Base
    attr_reader :year
    attr_reader :month
    attr_reader :day

    def initialize(location, year, month, day)
      super(location)
      @year = year
      @month = month
      @day = day
    end

    def ==(other)
      super &&
        (year == other.year) &&
        (month == other.month) &&
        (day == other.day)
    end

    def interpret(context)
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{year}-#{month}-#{day})" ]
      ]
    end
  end
end
