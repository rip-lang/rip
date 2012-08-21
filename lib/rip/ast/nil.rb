require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Nil < Rip::AST::Base
    def value
      nil
    end
  end
end
