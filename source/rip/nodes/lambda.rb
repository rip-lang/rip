module Rip::Nodes
  class Lambda < Base
    attr_reader :overloads

    def initialize(location, overloads)
      super(location)
      @overloads = Rip::Nodes::Overload.expand(overloads)
    end

    def ==(other)
      super &&
        (overloads == other.overloads)
    end

    def interpret(context)
      _context = context.nested_context

      _overloads = overloads.map do |overload|
        overload.interpret(_context)
      end

      Rip::Core::Lambda.new(context, _overloads)
    end

    def to_debug(level = 0)
      overloads_debug = overloads.inject([]) do |memo, overload|
        memo + overload.to_debug(level + 2)
      end

      body_debug = [ [ level + 1, 'overloads = [' ] ] +
        overloads_debug +
        [ [ level + 1, ']' ] ]

      [
        [ level, "#{super.last.last}" ]
      ] + body_debug
    end
  end
end
