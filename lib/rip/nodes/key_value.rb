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

    def to_debug(level = 0)
      key_debug = [ [ level + 1, 'key = [' ] ] +
        key.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      value_debug = [ [ level + 1, 'value = [' ] ] +
        value.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + key_debug + value_debug
    end
  end
end
