module Rip::Nodes
  class Interpolation < Base
    attr_reader :expressions

    def initialize(location, expressions)
      super(location)
      @expressions = expressions
    end

    def ==(other)
      super &&
        (expressions == other.expressions)
    end
  end
end
