require 'parslet'

require 'rip'
require 'rip/parsers/object'
require 'rip/parsers/reference'

module Rip::Parsers
  module Invocation
    include Parslet
    include Rip::Parsers::Object
    include Rip::Parsers::Reference

    rule(:invocation) { regular_invocation }

    rule(:regular_invocation) { ((lambda_literal | reference) >> surround_with('(', thing_list(object).as(:arguments), ')')).as(:invocation) }
  end
end
