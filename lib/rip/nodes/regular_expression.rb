require 'rip/nodes'

module Rip::Nodes
  class RegularExpression
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def ==(other)
      data == other.data
    end

    def evaluate
    end
  end
end
