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
  end
end
