module Rip::Nodes
  class Assignment < Base
    attr_reader :lhs
    attr_reader :rhs

    def initialize(location, lhs, rhs)
      super(location)
      @lhs = lhs
      @rhs = rhs
    end

    def interpret(context)
      lhs.interpret_for_assignment(context) do
        rhs.interpret(context)
      end
    end

    def to_debug(level = 0)
      lhs_line_1, *lhs_other_lines = lhs.to_debug(level + 1)
      lhs_debug = [ [ level + 1, "lhs = #{Array(lhs_line_1).last}" ] ] +
        lhs_other_lines

      rhs_line_1, *rhs_other_lines = rhs.to_debug(level + 1)
      rhs_debug = [ [ level + 1, "rhs = #{Array(rhs_line_1).last}" ] ] +
        rhs_other_lines

      super + lhs_debug + rhs_debug
    end
  end
end
