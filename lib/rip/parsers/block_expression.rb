require 'parslet'

require 'rip'
require 'rip/parsers/helpers'

module Rip::Parsers
  module BlockExpression
    include Parslet
    include Rip::Parsers::Helpers

    rule(:block_expression) { condition | loop_block | exception_handling }

    def block(body = statements)
      surround_with('{', body.as(:body), '}')
    end
  end
end
