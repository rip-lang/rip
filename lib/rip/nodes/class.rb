module Rip::Nodes
  class Class < Base
    attr_reader :superclasses
    attr_reader :body

    def initialize(location, superclasses, body)
      super(location)
      @superclasses = superclasses
      @body = body
    end

    def ==(other)
      super &&
        (superclasses == other.superclasses) &&
        (body == other.body)
    end

    def interpret(context)
      Rip::Core::Class.new.tap do |reply|
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
      superclasses_debug_inner = superclasses.inject([]) do |reply, superclass|
        reply + superclass.to_debug(level + 2)
      end

      superclasses_debug = [ [ level + 1, 'superclasses = [' ] ] +
        superclasses_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + superclasses_debug + body_debug
    end
  end
end
