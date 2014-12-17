module Rip::Nodes
  class Decimal < Number
    def interpret(context)
      parts = data.split('.')

      denominator = 10 ** parts.last.size
      numerator = (parts.first.to_i * denominator) + parts.last.to_i

      Rip::Core::Rational.new(numerator, denominator, sign)
    end
  end
end
