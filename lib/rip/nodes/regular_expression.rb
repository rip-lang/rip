module Rip::Nodes
  class RegularExpression < Base
    attr_reader :pattern

    def initialize(location, pattern)
      super(location)
      @pattern = pattern
    end
  end
end
