require 'ostruct'
require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Range < Rip::AST::Base
    def value
      OpenStruct.new :start => elements.first, :end => elements.last
    end
  end
end
