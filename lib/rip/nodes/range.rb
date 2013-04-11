module Rip::Nodes
  class Range < Base
    attr_reader :start
    attr_reader :end
    attr_reader :exclusivity

    def initialize(location, start, ending, exclusivity = false)
      super(location)
      @start = start
      @end = ending
      @exclusivity = exclusivity
    end

    def ==(other)
      super &&
        (start == other.start) &&
        (self.end == other.end) &&
        (exclusivity == other.exclusivity)
    end
  end
end
