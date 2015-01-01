module Rip::Nodes
  class Integer < Number
    def interpret(context)
      Rip::Core::Integer.new(data.to_i, sign)
    end
  end
end
