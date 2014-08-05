module Rip::Nodes
  class Parameter < Base
    attr_reader :location
    attr_reader :name

    def initialize(location, name, type = nil)
      super(location)

      @name = name
      @type = type
    end

    def ==(other)
      (name == other.name) &&
        (raw_type == other.raw_type)
    end

    def bind(context, argument)
      _type = type(context)

      unless argument['class'].ancestors.include?(_type) || special_case_for_class?(argument['class'])
        raise Rip::Exceptions::CompilerException.new("Parameter type mis-match: expected `#{name}` to be a `#{_type}`, but was a `#{argument['class']}`", location)
      end

      context.tap do |reply|
        reply[name] = argument
      end
    end

    def matches?(context, argument_type)
      argument_type.ancestors.include?(type(context)) || special_case_for_class?(argument_type)
    end

    def raw_type
      @type
    end

    def required?
      true
    end

    def type(context)
      case @type
        when Rip::Core::Base  then @type
        when Rip::Nodes::Base then @type.interpret(context)
        else                       Rip::Core::Object.class_instance
      end.tap do |reply|
        @type = reply
      end
    end

    def to_debug(level = 0)
      if default_expression
        default_line_1, *default_other_lines = default_expression.to_debug(level + 1)
        default_debug = [ [ level + 1, "default = #{Array(default_line_1).last}" ] ] +
          default_other_lines

        [
          [ level, "#{super.last.last} (#{name})" ]
        ] + default_debug
      else
        [
          [ level, "#{super.last.last} (#{name})" ]
        ]
      end
    end

    protected

    def special_case_for_class?(argument_type)
      raise 'special_case_for_class? called out of turn' unless raw_type.is_a?(Rip::Core::Base)

      (argument_type == Rip::Core::Class.class_instance) &&
        (raw_type == Rip::Core::Object.class_instance)
    end

    def special_case_for_class?(argument_type)
      raise 'special_case_for_class? called out of turn' unless raw_type.is_a?(Rip::Core::Base)

      (argument_type == Rip::Core::Class.class_instance) &&
        (raw_type == Rip::Core::Object.class_instance)
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

    def bind(context, argument)
      if argument
        super(context, argument)
      else
        super(context, default_expression.interpret(context))
      end
    end

    def required?
      false
    end
  end
end
