module Rip::Nodes
  class Assignment < Base
    attr_reader :lhs
    attr_reader :rhs

    def initialize(location, lhs, rhs)
      super(location)
      @lhs = lhs
      @rhs = rhs
    end

    def to_debug(level = 0)
      lhs_debug = [ [ level + 1, 'lhs =' ] ] +
        lhs.to_debug(level + 2)

      rhs_debug = [ [ level + 1, 'rhs =' ] ] +
        rhs.to_debug(level + 2)

      super + lhs_debug + rhs_debug
    end
  end
end
