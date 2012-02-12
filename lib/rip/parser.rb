require 'parslet'
require 'pathname'

module Rip
  class Parser < Parslet::Parser
    root(:statements)

    rule(:statement) { comment }
    rule(:statements) { statement.repeat }

    rule(:comment) { (str('#') >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    #---------------------------------------------

    rule(:eol) { str("\r\n") | str("\n") | str("\r") }

    #---------------------------------------------

    def parse_file(path)
      parse(path.read)
    end
  end
end
