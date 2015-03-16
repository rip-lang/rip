module Rip::Nodes
  class Parameter < Base
    attr_reader :location
    attr_reader :name
    attr_reader :type

    def initialize(location, name, type = nil)
      super(location)

      @name = name
      @type = type
    end

    def ==(other)
      (name == other.name) &&
        (type == other.type)
    end

    def interpret(context)
      _type = type ? type.interpret(context) : Rip::Core::Object.type_instance
      Rip::Core::Parameter.new(name, _type)
    end

    def resolve
      self
    end

    def required?
      true
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{name})" ]
      ]
    end
  end

  class DefaultParameter < Rip::Nodes::Parameter
    attr_reader :default_expression

    def initialize(location, name, type = nil, default_expression = nil)
      super(location, name, type)

      @default_expression = default_expression
    end

    def ==(other)
      super &&
        (default_expression == other.default_expression)
    end

    def required?
      false
    end
  end
end
