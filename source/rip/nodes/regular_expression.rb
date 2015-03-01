module Rip::Nodes
  class RegularExpression < Base
    attr_reader :pattern

    def initialize(location, pattern)
      super(location)
      @pattern = pattern
    end

    def interpret(context)
    end

    def resolve
      self
    end

    def to_debug(level = 0)
      pattern_debug = pattern.map(&:data).join('')

      [
        [ level, "#{super.last.last} (#{pattern_debug})" ]
      ]
    end
  end
end
