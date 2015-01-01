module Rip::Nodes
  class Else < Base
    attr_reader :body

    def initialize(location, body)
      super(location)
      @body = body
    end

    def ==(other)
      super &&
        (body == other.body)
    end

    def interpret(context)
      body.interpret(context)
    end

    def to_debug(level = 0)
      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + body_debug
    end
  end
end
