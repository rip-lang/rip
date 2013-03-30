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
  end
end
