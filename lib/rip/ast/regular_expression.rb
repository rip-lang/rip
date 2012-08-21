require 'rip'
require 'rip/ast'
require 'rip/ast/base'

module Rip::AST
  class RegularExpression < Rip::AST::Base
    def value
      Regexp.new elements[1].text_value
    end
  end
end
