require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Assignment < Rip::AST::Base
    def children
      [
        elements.first,
        elements.last.elements.first
      ]
    end
  end
end
