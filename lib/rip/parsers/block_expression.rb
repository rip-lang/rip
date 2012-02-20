require 'parslet'

require 'rip'
require 'rip/parsers/helpers'

module Rip::Parsers
  module BlockExpression
    include Parslet
    include Rip::Parsers::Helpers

    rule(:block_expression) { condition | loop_block | exception_handling }

    rule(:conditional) { if_prefix | unless_prefix | switch }

    #---------------------------------------------

    rule(:binary_condition) { surround_with('(', object.as(:binary_condition), ')') }

    rule(:if_prefix) do
      (str('if') >> spaces? >> binary_condition >> spaces? >> block  >> whitespaces? >> else_block.maybe).as(:if_prefix)
    end

    rule(:elseif_block) { (str('elseif') >> spaces? >> binary_condition >> spaces? >> block).as(:elseif) }

    rule(:else_block) { (str('else') >> whitespaces? >> block).as(:else) }

    rule(:unless_prefix) do
      (str('unless') >> spaces? >> binary_condition >> spaces? >> block  >> whitespaces? >> else_block.maybe).as(:unless_prefix)
    end

    #---------------------------------------------

    rule(:switch) do
      switch_test = surround_with('(', object.as(:switch_test).maybe, ')')
      cases = case_block.repeat(1) >> whitespaces? >> else_block.maybe
      (str('switch') >> spaces? >> switch_test.maybe >> spaces? >> block(cases)).as(:switch)
    end

    rule(:case_block) do
      case_qualifiers = surround_with('(', thing_list(object, str(',')).as(:case_qualifiers).maybe, ')')
      (str('case') >> whitespaces? >> case_qualifiers.maybe >> whitespaces? >> block).as(:case)
    end

    #---------------------------------------------

    def block(body = statements)
      surround_with('{', body.as(:body), '}')
    end
  end
end
