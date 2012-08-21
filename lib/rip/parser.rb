require 'parslet'
require 'pathname'

require 'rip/parsers/block_expression'
require 'rip/parsers/helpers'
require 'rip/parsers/simple_expression'

module Rip
  class Parser < Parslet::Parser
    include Rip::Parsers::BlockExpression
    include Rip::Parsers::Helpers
    include Rip::Parsers::SimpleExpression

    root(:statements)

    # statement
    #   comment
    #   expression (literal, invocation or reference eg: 2 + 2, full_name())
    #   assignment (reference = expression eg: answer = 2 + 2, name = full_name())
    #   block (if, unless, switch, case, try)
    #   (expression | assignment | block) comment

    rule(:statement) { (comment | expression) >> spaces? >> comment.maybe }
    rule(:statements) { thing_list(statement, whitespaces?) }

    rule(:comment) { (str('#') >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    rule(:expression) { (simple_expression | block_expression) }

    def parse_file(path)
      parse(path.read)
    end
  end
end
