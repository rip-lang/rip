require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Reference < Rip::AST::Base
    def name
      text_value
    end

    def value
      parent.elements.last.elements.first
    end
  end
end
