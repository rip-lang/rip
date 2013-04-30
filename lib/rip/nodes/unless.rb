module Rip::Nodes
  class Unless < Base
    attr_reader :argument
    attr_reader :false_body
    attr_reader :true_body

    def initialize(location, argument, false_body, true_body)
      super(location)
      @argument = argument
      @false_body = false_body
      @true_body = true_body
    end

    def ==(other)
      super &&
        (argument == other.argument) &&
        (false_body == other.false_body) &&
        (true_body == other.true_body)
    end

    def to_debug(level = 0)
      argument_debug = [ [ level + 1, 'argument =' ] ] +
        argument.to_debug(level + 2)

      false_body_debug = [ [ level + 1, 'false_body = [' ] ] +
        false_body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      true_body_debug = [ [ level + 1, 'true_body = [' ] ] +
        true_body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      super + argument_debug + false_body_debug + true_body_debug
    end
  end
end
