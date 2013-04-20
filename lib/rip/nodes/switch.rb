module Rip::Nodes
  class Switch < Base
    attr_reader :argument
    attr_reader :case_blocks
    attr_reader :else_block

    def initialize(location, argument, case_blocks, else_block = nil)
      super(location)
      @argument = argument
      @case_blocks = case_blocks
      @else_block = else_block
    end

    def ==(other)
      super &&
        (argument == other.argument) &&
        (case_blocks == other.case_blocks) &&
        (else_block == other.else_block)
    end
  end
end
