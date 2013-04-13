module Rip::Nodes
  class Try < Base
    attr_reader :body

    def initialize(location, body)
      super(location)
      @body = body
    end

    def ==(other)
      super &&
        (body == other.body)
    end
  end
end
