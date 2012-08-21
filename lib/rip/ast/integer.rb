require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Integer < Rip::AST::Base
    def value
      Integer text_value
    end
  end
end
