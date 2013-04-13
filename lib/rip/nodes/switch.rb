module Rip::Nodes
  class Switch < Base
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
  end
end
