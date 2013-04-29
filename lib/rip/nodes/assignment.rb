module Rip::Nodes
  class Assignment < Base
    attr_reader :lhs
    attr_reader :rhs

    def initialize(location, lhs, rhs)
      super(location)
      @lhs = lhs
      @rhs = rhs
    end
  end
end
