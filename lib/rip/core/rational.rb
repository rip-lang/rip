module Rip::Core
  class Rational < Rip::Core::Base
    attr_reader :data
    attr_reader :sign

    def initialize(data, sign = :+)
      super()
      @data = data
      @sign = sign.to_sym
    end
  end
end
