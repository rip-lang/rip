require 'rip/nodes'

module Rip::Nodes
  class Character
    attr_reader :data

    def initialize(data)
      @data = data.to_sym
    end

    def ==(other)
      data == other.data
    end

    def evaluate
    end
  end
end
