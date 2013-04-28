module Rip::Nodes
  class Base
    attr_reader :location

    def initialize(location)
      @location = location
    end

    def ==(other)
      other.respond_to?(:location) &&
        location == other.location
    end

    def to_debug(level = 0)
      [
        [ level, "#{self.class.short_name}@#{location.to_debug}" ]
      ]
    end

    def self.short_name
      name.sub('Rip::Nodes::', '')
    end
  end
end
