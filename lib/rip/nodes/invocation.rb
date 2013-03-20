module Rip::Nodes
  class Invocation < Base
    attr_reader :callable
    attr_reader :arguments

    def initialize(location, callable, arguments)
      super(location)
      @callable = callable
      @arguments = arguments
    end

    def ==(other)
      super &&
        (callable == other.callable) &&
        (arguments == other.arguments)
    end
  end
end
