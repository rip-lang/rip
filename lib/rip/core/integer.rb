module Rip::Core
  class Integer < Rip::Core::Base
    attr_reader :data
    attr_reader :sign

    def initialize(data, sign = :+)
      super()
      @data = data
      @sign = sign.to_sym
    end

    def ==(other)
      (data == other.data) &&
        (sign == other.sign)
    end
  end
end
