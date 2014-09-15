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

    def interpret(context)
      _context = context.nested_context

      _argument = if argument
        argument.interpret(_context)
      else
        Rip::Core::Boolean.true
      end

      case_block = case_blocks.detect do |case_block|
        case_block.matches?(_context, _argument)
      end

      if case_block
        case_block.interpret(_context)
      else
        else_block.interpret(_context)
      end
    end

    def to_debug(level = 0)
      argument_debug = [ [ level + 1, 'argument =' ] ] +
        argument.to_debug(level + 2)

      case_blocks_debug = case_blocks.inject([]) do |reply, case_block|
        reply + case_block.to_debug(level + 1)
      end

      super + argument_debug + case_blocks_debug + else_block.to_debug(level + 1)
    end
  end
end
