module Rip::Nodes
  class BlockBody < Base
    attr_reader :statements

    def initialize(location, statements)
      super(location)
      @statements = statements
    end

    def ==(other)
      super &&
        (statements == other.statements)
    end

    def interpret(context, &block)
      _context = context.nested_context

      statements.map do |statement|
        if block_given?
          block.call(statement) || statement.interpret(_context)
        else
          statement.interpret(_context)
        end
      end.last
    end

    def to_debug(level = 0)
      statements.inject([]) do |reply, statement|
        reply + statement.to_debug(level)
      end
    end
  end
end
