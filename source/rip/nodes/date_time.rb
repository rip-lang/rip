module Rip::Nodes
  class DateTime < Base
    attr_reader :date
    attr_reader :time

    def initialize(location, date, time)
      super(location)
      @date = date
      @time = time
    end

    def ==(other)
      super &&
        (date == other.date) &&
        (time == other.time)
    end

    def interpret(context)
    end

    def to_debug(level = 0)
      date_debug = date.to_debug(level + 1)

      time_debug = time.to_debug(level + 1)

      super + date_debug + time_debug
    end
  end
end
