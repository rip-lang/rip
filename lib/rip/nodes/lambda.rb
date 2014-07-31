module Rip::Nodes
  class Lambda < Base
    attr_reader :overloads

    def initialize(location, overloads)
      super(location)
      @overloads = Rip::Nodes::Overload.expand(overloads)
    end

    def ==(other)
      super &&
        (overloads == other.overloads)
    end

    def interpret(context)
      _overloads = overloads.map do |overload|
        overload.interpret(context)
      end

      Rip::Core::Lambda.new(context, _overloads)
    end

    def to_debug(level = 0)
      parameters_debug_inner = parameters.inject([]) do |reply, parameter|
        reply + parameter.to_debug(level + 2)
      end

      parameters_debug = [ [ level + 1, 'parameters = [' ] ] +
        parameters_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      [
        [ level, super.last.last ]
      ] + parameters_debug + body_debug
    end
  end
end
