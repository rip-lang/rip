require 'ostruct'
require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class KeyValuePair < Rip::AST::Base
    def value
      OpenStruct.new :key => elements.first, :value => elements.last
    end
  end
end
