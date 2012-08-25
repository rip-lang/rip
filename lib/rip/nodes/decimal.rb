require 'rip/nodes'

module Rip::Nodes
  class Decimal
    attr_reader :data
    attr_reader :sign

    def initialize(number, sign = :+)
      @data = Float number
      @sign = sign
    end

    def ==(other)
      (data == other.data) &&
        (sign == other.sign)
    end

    def evaluate
    end
  end
end
