module Rip::Nodes
  class Property < Base
    attr_reader :object
    attr_reader :name

    def initialize(location, object, name)
      super(location)
      @object = object
      @name = name.to_s
    end

    def ==(other)
      super &&
        (object == other.object) &&
        (name == other.name)
    end

    def interpret(context)
      object.interpret(context)[name] ||
        (raise Rip::Exceptions::RuntimeException.new("Unknown property `#{name}`", location))
    end

    def interpret_for_assignment(context, &block)
      object.interpret(context)[name] = block.call
    end

    def to_debug(level = 0)
      object_line_1, *object_other_lines = object.to_debug(level + 1)
      object_debug = [ [ level + 1, "object = #{Array(object_line_1).last}" ] ] +
        object_other_lines

      name_debug = [ [ level + 1, "name = #{name}" ] ]

      super + object_debug + name_debug
    end
  end
end
