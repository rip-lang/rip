module Rip::Nodes
  class Class < Base
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

    def to_debug(level = 0)
      arguments_debug = arguments.inject([]) do |reply, argument|
        reply + argument.to_debug(level + 1)
      end

      super + arguments_debug + body.to_debug(level + 1)
    end
  end
end
