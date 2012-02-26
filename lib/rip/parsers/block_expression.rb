require 'parslet'

require 'rip'
require 'rip/parsers/construct'
require 'rip/parsers/helpers'
require 'rip/parsers/keyword'
require 'rip/parsers/object'

module Rip::Parsers
  module BlockExpression
    include Parslet
    include Rip::Parsers::Construct
    include Rip::Parsers::Helpers
    include Rip::Parsers::Keyword
    include Rip::Parsers::Object

    # NOTE anything that should not be followed by an expression terminator
    rule(:block_expression) { conditional | exception_handling }

    rule(:conditional) { if_prefix | unless_prefix | switch }


    #---------------------------------------------

    [:if, :unless].each do |cond|
      name = "#{cond}_prefix".to_sym
      rule(name) { (send("#{cond}_condition") >> spaces? >> block  >> whitespaces? >> else_block.maybe).as(name) }
    end

    rule(:else_block) { (else_keyword >> whitespaces? >> block).as(:else) }

    #---------------------------------------------

    rule(:switch) do
      switch_test = surround_with('(', object.as(:switch_test).maybe, ')')
      cases = case_block.repeat(1) >> whitespaces? >> else_block.maybe
      (switch_keyword >> spaces? >> switch_test.maybe >> spaces? >> block(cases)).as(:switch)
    end

    rule(:case_block) do
      case_qualifiers = surround_with('(', thing_list(object, str(',')).as(:case_qualifiers).maybe, ')')
      (case_keyword >> whitespaces? >> case_qualifiers.maybe >> whitespaces? >> block).as(:case)
    end

    #---------------------------------------------

    rule(:exception_handling) do
      try_block = (try_keyword >> whitespaces? >> block).as(:try)
      catch_block = (catch_keyword >> whitespaces? >> surround_with('(', key_value_pair, ')') >> whitespaces? >> block).as(:catch)
      finally = (finally_keyword >> whitespaces? >> block).as(:finally)

      (try_block >> whitespaces? >> catch_block.repeat(1) >> whitespaces? >> finally.maybe).as(:exception_handling)
    end
  end
end
