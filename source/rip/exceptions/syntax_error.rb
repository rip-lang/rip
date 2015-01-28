module Rip::Exceptions
  class SyntaxError < CompilerException
    attr_reader :ascii_tree

    status_code 13

    def initialize(message, location, call_stack = [], ascii_tree = nil)
      super(message, location, call_stack)
      @ascii_tree = ascii_tree
    end

    def dump
      <<-DUMP
#{super}

ASCII Tree:
#{ascii_tree}
      DUMP
    end
  end
end
