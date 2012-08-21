require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class List < Rip::AST::Base
    def value
      []
    end
  end
end
