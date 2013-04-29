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

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{name})" ]
      ]
    end
  end
end
