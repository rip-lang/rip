module Rip::Nodes
  class Reference < Base
    attr_reader :name

    def initialize(location, name)
      super(location)
      @name = name
    end

    def ==(other)
      super &&
        (name == other.name)
    end
  end
end
