require 'parslet'
require 'pathname'

require 'rip/parsers/block_expression'
require 'rip/parsers/helpers'
require 'rip/parsers/object'
require 'rip/parsers/simple_expression'

module Rip
  class Parser < Parslet::Parser
    include Rip::Parsers::BlockExpression
    include Rip::Parsers::Helpers
    include Rip::Parsers::Object
    include Rip::Parsers::SimpleExpression

    root(:statements)

    rule(:statement) { comment | expression >> spaces? >> comment.maybe }
    rule(:statements) { thing_list(statement, whitespaces?) }

    rule(:comment) { (str('#') >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    rule(:expression) { simple_expression | block_expression }

    rule(:expression_terminator) { str(';') | eol }
    rule(:expression_terminator?) { expression_terminator.maybe }

    def parse_file(path)
      parse(path.read)
    end
  end
end
