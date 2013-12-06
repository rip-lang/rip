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

    def interpret(context)
    end

    def to_debug(level = 0)
      callable_line_1, *callable_other_lines = callable.to_debug(level + 1)
      callable_debug = [ [ level + 1, "callable = #{Array(callable_line_1).last}" ] ] +
        callable_other_lines

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
