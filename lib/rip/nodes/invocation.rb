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

    def to_debug(level = 0)
      callable_debug = [ [ level + 1, 'callable = [' ] ] +
        callable.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      arguments_debug_inner = arguments.inject([]) do |reply, argument|
        reply + argument.to_debug(level + 2)
      end

      arguments_debug = [ [ level + 1, 'arguments = [' ] ] +
        arguments_debug_inner +
        [ [ level + 1, ']' ] ]

      super + callable_debug + arguments_debug
    end
  end
end
