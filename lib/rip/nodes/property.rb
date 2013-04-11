module Rip::Nodes
  class Property < Base
    attr_reader :object
    attr_reader :name

    def initialize(location, object, name)
      super(location)
      @object = object
      @name = name
    end

    def ==(other)
      super &&
        (object == other.object) &&
        (name == other.name)
    end
  end
end
