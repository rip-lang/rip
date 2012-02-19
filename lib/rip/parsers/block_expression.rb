require 'parslet'

require 'rip'
require 'rip/parsers/helpers'

module Rip::Parsers
  module BlockExpression
    include Parslet
    include Rip::Parsers::Helpers

    rule(:block_expression) { condition | loop_block | exception_handling }

    rule(:block) { surround_with('{', statements.as(:body), '}') }
  end
end
