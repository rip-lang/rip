require 'rip/nodes'

module Rip::Nodes
  class List
    attr_reader :items

    def initialize(*items)
      @items = items
    end

    def ==(other)
      other.respond_to?(:items) && (items == other.items)
    end

    def evaluate
    end
  end
end
