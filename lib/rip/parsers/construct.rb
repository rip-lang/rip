require 'parslet'

require 'rip'
require 'rip/parsers/helpers'
require 'rip/parsers/keyword'
require 'rip/parsers/object'

module Rip::Parsers
  module Construct
    include Parslet
    include Rip::Parsers::Helpers
    include Rip::Parsers::Keyword
    include Rip::Parsers::Object

    rule(:if_condition) { if_keyword >> spaces? >> binary_condition }
    rule(:unless_condition) { unless_keyword >> spaces? >> binary_condition }

    # NOTE phrase is defined in Rip::Parsers::SimpleExpression and will be available when needed
    rule(:binary_condition) { surround_with('(', phrase.as(:binary_condition), ')') }
  end
end
