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
  end
end
