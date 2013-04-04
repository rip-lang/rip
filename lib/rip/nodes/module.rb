module Rip::Nodes
  class Module < Base
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
