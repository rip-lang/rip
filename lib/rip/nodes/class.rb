module Rip::Nodes
  class Class < Base
    attr_reader :super_types
    attr_reader :body

    def initialize(location, super_types, body)
      super(location)
      @super_types = super_types
      @body = body
    end

    def ==(other)
      super &&
        (super_types == other.super_types) &&
        (body == other.body)
    end

    def interpret(context)
      _super_types = super_types.map do |super_type|
        super_type.interpret(context)
      end

      Rip::Core::Class.new(_super_types).tap do |reply|
        body.interpret(context) do |statement|
          if statement.is_a?(Rip::Nodes::Assignment)
            statement.lhs.interpret_for_assignment(reply) do
              begin
                statement.rhs.interpret(reply)
              rescue Rip::Exceptions::RuntimeException => e
                statement.rhs.interpret(context)
              end
            end
          end
        end
      end
    end

    def to_debug(level = 0)
      super_types_debug_inner = super_types.inject([]) do |reply, super_type|
        reply + super_type.to_debug(level + 2)
      end

      super_types_debug = [ [ level + 1, 'super_types = [' ] ] +
        super_types_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + super_types_debug + body_debug
    end
  end
end
