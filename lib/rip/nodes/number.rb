module Rip::Nodes
  class Number < Base
    attr_reader :data
    attr_reader :sign

    def initialize(location, data, sign = :+)
      super(location)
      @data = data
      @sign = sign.to_sym
    end

    def ==(other)
      super &&
        (data == other.data) &&
        (sign == other.sign)
    end
  end
end
