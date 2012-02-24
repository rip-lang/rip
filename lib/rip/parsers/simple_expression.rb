require 'parslet'

require 'rip'
require 'rip/parsers/construct'
require 'rip/parsers/invocation'
require 'rip/parsers/object'

module Rip::Parsers
  module SimpleExpression
    include Parslet
    include Rip::Parsers::Construct
    include Rip::Parsers::Object
    include Rip::Parsers::Invocation

    rule(:simple_expression) { simple_expression_fancy >> spaces? >> expression_terminator? }

    rule(:simple_expression_fancy) { (exiter >> spaces).maybe >> (assignment | invocation | object) >> (spaces >> (if_postfix | unless_postfix)).maybe }

    rule(:expression_terminator) { str(';') | eol }
    rule(:expression_terminator?) { expression_terminator.maybe }

    #---------------------------------------------

    [:if, :unless].each do |cond|
      name = "#{cond}_postfix".to_sym
      rule(name) { send("#{cond}_condition").as(name) }
    end
  end
end
