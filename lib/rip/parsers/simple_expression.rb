require 'parslet'

require 'rip'

module Rip::Parsers
  module SimpleExpression
    include Parslet

    rule(:simple_expression) { simple_expression_fancy >> expression_terminator? }

    rule(:simple_expression_fancy) { assignment | object }
  end
end
