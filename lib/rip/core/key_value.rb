module Rip::Core
  class KeyValue < Rip::Core::Base
    attr_reader :key
    attr_reader :value

    def initialize(key, value)
      super()
      @key = key
      @value = value
    end
  end
end
