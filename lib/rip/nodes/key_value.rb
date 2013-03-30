module Rip::Nodes
  class KeyValue < Base
    attr_reader :key
    attr_reader :value

    def initialize(location, key, value)
      super(location)
      @key = key
      @value = value
    end

    def ==(other)
      super &&
        (key == other.key) &&
        (value == other.value)
    end
  end
end
