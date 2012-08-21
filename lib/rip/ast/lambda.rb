require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Lambda < Rip::AST::Base
    def value
      OpenStruct.new :parameters => []
    end
  end
end
