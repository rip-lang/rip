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

    rule(:binary_condition) { surround_with('(', object.as(:binary_condition), ')') }
  end
end
