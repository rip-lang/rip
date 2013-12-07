module Rip::Core
  class Base
    attr_reader :properties

    def initialize
      @properties = {}
    end

    def ==(other)
      properties == other.properties
    end

    def [](key)
      properties[key] ||
        properties['class']['@'][key]
    end

    def []=(key, value)
      properties[key] = value
    end
  end
end
