module Rip::Nodes
  class If < Base
    attr_reader :argument
    attr_reader :true_body
    attr_reader :false_body

    def initialize(location, argument, true_body, false_body)
      super(location)
      @argument = argument
      @true_body = true_body
      @false_body = false_body
    end

    def ==(other)
      super &&
        (argument == other.argument) &&
        (true_body == other.true_body) &&
        (false_body == other.false_body)
    end

    def interpret(context)
      _argument = argument.interpret(context)['to_boolean'].call(context, [])

      if _argument == Rip::Core::Boolean.true
        true_body.interpret(context)
      else
        false_body.interpret(context)
      end
    end

    def resolve
      self
    end

    def to_debug(level = 0)
      argument_debug = [ [ level + 1, 'argument =' ] ] +
        argument.to_debug(level + 2)

      true_body_debug = [ [ level + 1, 'true_body = [' ] ] +
        true_body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      false_body_debug = [ [ level + 1, 'false_body = [' ] ] +
        false_body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + argument_debug + true_body_debug + false_body_debug
    end
  end
end
