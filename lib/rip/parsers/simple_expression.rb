require 'parslet'

require 'rip'
require 'rip/parsers/object'

module Rip::Parsers
  module SimpleExpression
    include Parslet
    include Rip::Parsers::Object

    rule(:simple_expression) { simple_expression_fancy >> expression_terminator? }

    rule(:simple_expression_fancy) { assignment | object }

    rule(:expression_terminator) { str(';') | eol }
    rule(:expression_terminator?) { expression_terminator.maybe }
  end
end
