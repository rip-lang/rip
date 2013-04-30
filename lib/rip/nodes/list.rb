module Rip::Nodes
  class List < Base
    attr_reader :items

    def initialize(location, items)
      super(location)
      @items = items
    end

    def ==(other)
      super &&
        (items == other.items)
    end

    def to_debug(level = 0)
      items_debug_inner = items.inject([]) do |reply, item|
        reply + item.to_debug(level + 2)
      end

      items_debug = [ [ level + 1, 'items = [' ] ] +
        items_debug_inner +
        [ [ level + 1, ']' ] ]

      super + items_debug
    end
  end
end
