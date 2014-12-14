module Rip::Core
  class Rational < Rip::Core::Base
    attr_reader :numerator
    attr_reader :denominator
    attr_reader :data

    def initialize(numerator, denominator, sign = :+)
      super()

      @numerator = numerator
      @denominator = denominator
      @data = Rational(numerator, denominator) * (sign.to_sym == :+ ? 1 : -1)

      self['type'] = self.class.type_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ "numerator = #{numerator}, denominator = #{denominator}" ]
    end

    define_type_instance('rational') do |type_instance|
      def type_instance.to_s
        '#< System.Rational >'
      end
    end
  end
end
