module Rip::Nodes
  class Module < Base
    attr_reader :body

    def initialize(location, body)
      super(location)
      @body = body
    end

    def ==(other)
      super &&
        (body == other.body)
    end

    def interpret(context)
      _context = Rip::Compiler::Scope.new(context, location.origin)
      body.interpret(_context)
    end

    def to_debug(level = 0)
      super + body.to_debug(level + 1)
    end
  end
end
