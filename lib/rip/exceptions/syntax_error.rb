module Rip::Exceptions
  class SyntaxError < CompilerException
    attr_reader :ascii_tree

    status_code 13

    def initialize(message, location = nil, call_stack = [], ascii_tree = nil)
      super(message, location, call_stack)
      @ascii_tree = ascii_tree
    end

    def dump
      [
        inspect,
        ascii_tree
      ]
    end
  end
end
