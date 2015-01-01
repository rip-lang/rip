module Rip::Nodes
  class Case < Base
    attr_reader :arguments
    attr_reader :body

    def initialize(location, arguments, body)
      super(location)
      @arguments = arguments
      @body = body
    end

    def ==(other)
      super &&
        (arguments == other.arguments) &&
        (body == other.body)
    end

    def interpret(context)
      body.interpret(context)
    end

    def matches?(context, argument)
      arguments.any? do |_argument|
        _argument.interpret(context)['==='].call([ argument ]).to_native
      end
    end

    def to_debug(level = 0)
      arguments_debug_inner = arguments.inject([]) do |reply, argument|
        reply + argument.to_debug(level + 2)
      end

      arguments_debug = [ [ level + 1, 'arguments = [' ] ] +
        arguments_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + arguments_debug + body_debug
    end
  end
end
