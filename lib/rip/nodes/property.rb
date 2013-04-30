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

    def to_debug(level = 0)
      object_debug = [ [ level + 1, 'object =' ] ] +
        object.to_debug(level + 2)

      name_debug = [ [ level + 1, "name = #{name}" ] ]

      super + object_debug + name_debug
    end
  end
end
