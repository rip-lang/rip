require 'parslet'

require 'rip'

module Rip::Parsers
  module Reference
    include Parslet

    # TODO consider multiple assignment
    rule(:assignment) { (reference >> spaces >> str('=') >> spaces >> expression.as(:value)).as(:assignment) }

    #---------------------------------------------

    rule(:reference) { simple_reference.as(:reference) }

    # http://www.rubular.com/r/sTue8ePXW9
    rule(:simple_reference) do
      legal = match['^.,;:\d\s()\[\]{}']
      legal.repeat(1) >> (legal | digit).repeat
    end
  end
end
