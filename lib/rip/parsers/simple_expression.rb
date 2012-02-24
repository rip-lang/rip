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

    rule(:simple_expression) do
      ((exiter >> spaces >> phrase) | exiter | phrase) >> (spaces >> postfix).maybe >> spaces? >> expression_terminator?
    end

    rule(:expression_terminator) { str(';') | eol }
    rule(:expression_terminator?) { expression_terminator.maybe }

    #---------------------------------------------

    rule(:postfix) { (if_postfix | unless_postfix) }

    rule(:phrase) { (postfix.absent? >> (assignment | invocation | object)) }

    #---------------------------------------------

    [:if, :unless].each do |cond|
      name = "#{cond}_postfix".to_sym
      rule(name) { send("#{cond}_condition").as(name) }
    end
  end
end
