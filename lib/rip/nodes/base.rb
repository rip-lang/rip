module Rip::Nodes
  class Base
    attr_reader :location

    def initialize(location)
      @location = location
    end

    def ==(other)
      location == other.location
    end
  end
end
