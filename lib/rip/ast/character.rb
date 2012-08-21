require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Character < Rip::AST::Base
    def value
      elements[1].text_value
    end
  end
end
