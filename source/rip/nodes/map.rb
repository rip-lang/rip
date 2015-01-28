module Rip::Nodes
  class Map < Base
    attr_reader :pairs

    def initialize(location, pairs = [])
      super(location)
      @pairs = pairs
    end

    def ==(other)
      super &&
        (pairs == other.pairs)
    end

    def interpret(context)
    end

    def to_debug(level = 0)
      pairs_debug_inner = pairs.inject([]) do |reply, pair|
        reply + pair.to_debug(level + 2)
      end

      pairs_debug = [ [ level + 1, 'pairs = [' ] ] +
        pairs_debug_inner +
        [ [ level + 1, ']' ] ]

      super + pairs_debug
    end
  end
end
