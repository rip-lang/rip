module Rip::Nodes
  class Module < Base
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
      body.interpret(context.nested_context)
    end

    def to_debug(level = 0)
      super + body.to_debug(level + 1)
    end
  end
end
