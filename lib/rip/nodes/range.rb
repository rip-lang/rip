module Rip::Nodes
  class Range < Base
    attr_reader :start
    attr_reader :end

    def initialize(location, start, ending)
      super(location)
      @start = start
      @end = ending
    end

    def ==(other)
      super &&
        (start == other.start) &&
        (self.end == other.end)
    end
  end
end
