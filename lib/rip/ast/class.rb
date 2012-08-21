require 'ostruct'
require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class Class < Rip::AST::Base
    def value
      OpenStruct.new :ancestors => ancestors
    end

    def ancestors
      #return [] unless respond_to? :superclasses
      return [] if superclasses.terminal?

      extractor = lambda do |node|
        reply = []
        reply << node if node.is_a?(self.class)
        reply << node.elements.map { |n| extractor.call(n) } if node.elements
        reply
      end

      extractor.call(superclasses).flatten
    end
  end
end
