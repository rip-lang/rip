module Rip::Nodes
  class Integer < Number
    def interpret(context)
      Rip::Core::Rational.new(data.to_i, 1, sign)
    end

    def resolve
      self
    end
  end
end
