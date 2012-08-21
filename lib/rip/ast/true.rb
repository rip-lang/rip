require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class True < Rip::AST::Base
    def value
      true
    end
  end
end
