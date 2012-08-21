require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class False < Rip::AST::Base
    def value
      false
    end
  end
end
