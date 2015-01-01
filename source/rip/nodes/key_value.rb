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

    def interpret(context)
    end

    def to_debug(level = 0)
      key_line_1, *key_other_lines = key.to_debug(level + 1)
      key_debug = [ [ level + 1, "key = #{Array(key_line_1).last}" ] ] +
        key_other_lines

      value_line_1, *value_other_lines = value.to_debug(level + 1)
      value_debug = [ [ level + 1, "value = #{Array(value_line_1).last}" ] ] +
        value_other_lines

      super + key_debug + value_debug
    end
  end
end
