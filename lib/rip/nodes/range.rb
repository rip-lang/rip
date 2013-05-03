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

    def to_debug(level = 0)
      start_line_1, *start_other_lines = start.to_debug(level + 1)
      start_debug = [ [ level + 1, "start = #{Array(start_line_1).last}" ] ] +
        start_other_lines

      end_line_1, *end_other_lines = self.end.to_debug(level + 1)
      end_debug = [ [ level + 1, "end = #{Array(end_line_1).last}" ] ] +
      end_other_lines

      exclusivity_debug = [
        [ level + 1, "exclusivity = #{exclusivity}" ]
      ]

      super + start_debug + end_debug + exclusivity_debug
    end
  end
end
