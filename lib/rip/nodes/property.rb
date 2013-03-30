module Rip::Nodes
  class Property < Base
    attr_reader :object
    attr_reader :property

    def initialize(location, object, property)
      super(location)
      @object = object
      @property = property
    end

    def ==(other)
      super &&
        (object == other.object) &&
        (property == other.property)
    end
  end
end
