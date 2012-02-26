require 'parslet'

require 'rip'

module Rip::Parsers
  module Reference
    include Parslet

    # TODO consider multiple assignment
    # TODO rules for visibility (public, protected, private)
    rule(:assignment) { (reference >> spaces >> str('=') >> spaces >> expression.as(:value)).as(:assignment) }

    #---------------------------------------------

    rule(:reference) { (special_reference | simple_reference).as(:reference) }

    rule(:special_reference) { (nil_literal | true_literal | false_literal | kernel_literal) >> reference_legal.absent? }

    # http://www.rubular.com/r/sTue8ePXW9
    rule(:simple_reference) { reference_legal.repeat(1) >> (reference_legal | digit).repeat }

    rule(:reference_legal) { match['^.,;:\d\s()\[\]{}'] }

    #---------------------------------------------

    rule(:nil_literal) { str('nil').as(:nil) }

    rule(:true_literal) { str('true').as(:true) }
    rule(:false_literal) { str('false').as(:false) }

    rule(:kernel_literal) { str('Kernel').as(:kernel) }
  end
end
