module Rip::Nodes
  class Parameter < Base
    attr_reader :location
    attr_reader :name
    attr_reader :default_expression

    def initialize(location, name, default_expression = nil)
      @location = location
      @name = name
      @default_expression = default_expression
    end

    def ==(other)
      (name == other.name) &&
        (default_expression == other.default_expression)
    end

    def bind(context, argument)
      value = if argument
        argument
      elsif default_expression
        default_expression.interpret(context)
      end

      BoundParameter.new(name, value) if value
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
  end

  class BoundParameter
    attr_reader :name
    attr_reader :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def inject(context)
      context[name] = value
      context
    end
  end
end
