module Rip::Nodes
  class Catch < Base
    attr_reader :argument
    attr_reader :body

    def initialize(location, argument, body)
      super(location)
      @argument = argument
      @body = body
    end

    def ==(other)
      super &&
        (argument == other.argument) &&
        (body == other.body)
    end

    def to_debug(level = 0)
      super + argument.to_debug(level + 1) + body.to_debug(level + 1)
    end
  end
end
