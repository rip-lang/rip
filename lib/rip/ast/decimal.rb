require 'rip/ast/base'

module Rip::AST
  class Decimal < Rip::AST::Base
    # FIXME return a real decimal number, not a float
    def value
      Float text_value
    end
  end
end
