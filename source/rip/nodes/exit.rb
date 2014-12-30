module Rip::Nodes
  class Exit < Base
    attr_reader :payload

    def initialize(location, payload)
      super(location)
      @payload = payload
    end

    def ==(other)
      super &&
        (payload == other.payload)
    end

    def interpret(context)
    end

    def to_debug(level = 0)
      super + payload.to_debug(level + 1)
    end
  end
end
