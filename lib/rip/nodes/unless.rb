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
  end
end
