module Rip::Nodes
  class Integer < Number
    def interpret(context)
      Rip::Core::Integer.new(data, sign)
    end
  end
end
