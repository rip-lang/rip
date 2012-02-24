require 'parslet'

require 'rip'
require 'rip/parsers/object'
require 'rip/parsers/reference'

module Rip::Parsers
  module Invocation
    include Parslet
    include Rip::Parsers::Object
    include Rip::Parsers::Reference

    rule(:invocation) { regular_invocation | operator_invocation }

    rule(:regular_invocation) { ((lambda_literal | reference) >> surround_with('(', thing_list(object).as(:arguments), ')')).as(:invocation) }

    rule(:operator_invocation) { (object.as(:operand) >> spaces >> reference.as(:operator) >> spaces >> object.as(:argument)).as(:invocation) }
  end
end
