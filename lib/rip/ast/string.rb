require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class String < Rip::AST::Base
    def value
      elements[1].elements.map(&:text_value)
    end
  end
end
