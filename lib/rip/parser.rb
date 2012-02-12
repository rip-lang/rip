require 'parslet'
require 'pathname'

module Rip
  class Parser < Parslet::Parser
    root(:statements)

    rule(:statement) { comment | expression >> spaces.maybe >> comment.maybe }
    rule(:statements) { statement.repeat }

    rule(:comment) { (str('#') >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    rule(:expression) { simple_expression }
    rule(:expression_terminator) { str(';') | eol }

    rule(:simple_expression) { simple_expression_fancy >> spaces.maybe >> expression_terminator.maybe }
    rule(:simple_expression_fancy) { object }

    #---------------------------------------------

    rule(:object) { simple_object }

    rule(:simple_object) { nil_literal | boolean | numeric | character | string | regular_expression }

    #---------------------------------------------

    rule(:nil_literal) { str('nil').as(:nil) }

    rule(:boolean) { true_literal | false_literal }

    rule(:true_literal) { str('true').as(:true) }

    rule(:false_literal) { str('false').as(:false) }

    #---------------------------------------------

    # WARNING order is important here: decimal must be before integer or the integral part of a decimal could be interpreted as a integer followed by a decimal starting with a '.' (dot)
    rule(:numeric) { decimal | integer }

    rule(:decimal) { (sign.maybe >> digits.maybe >> str('.') >> digits).as(:decimal) }

    rule(:integer) { (sign.maybe >> digits).as(:integer) }

    rule(:sign) { match['+-'] }

    rule(:digit) { match['0-9'] }

    # allow _ to be used to group digits ( 3_423_752 )
    # _ may not come first or last
    rule(:digits) { digit.repeat(1) >> (str('_').maybe >> digit.repeat(1)).repeat }

    #---------------------------------------------

    # FIXME should match any single printable unicode character
    rule(:character) { str('`') >> match['0-9a-zA-Z_'].as(:character) }

    #---------------------------------------------

    # NOTE a string is just a list with characters allowed in it
    rule(:string) { symbol_string | single_quoted_string | double_quoted_string | here_doc}

    # FIXME should match most printable characters except whitespace
    rule(:symbol_string) { str(':') >> match['a-zA-Z_'].repeat(1).as(:string) }

    rule(:single_quoted_string) { str('\'') >> (str('\'').absent? >> any).repeat.as(:string) >> str('\'') }

    rule(:double_quoted_string) { str('"') >> (str('"').absent? >> any).repeat.as(:string) >> str('"') }

    rule(:here_doc) do
      label = match['A-Z_'].repeat(1)
      start = str('<<') >> label.as(:here_doc_start) >> eol
      content = (label.absent? >> any).repeat.as(:string)
      finish = label.as(:here_doc_end) >> eol.maybe
      start >> content >> finish
    end

    #---------------------------------------------

    # TODO expand regular expression pattern
    rule(:regular_expression) { str('/') >> (str('/').absent? >> any).repeat.as(:regex) >> str('/') }

    #---------------------------------------------

    rule(:whitespace) { spaces | eols }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat }

    rule(:eol) { str("\r\n") | str("\n") | str("\r") }
    rule(:eols) { eol.repeat }

    #---------------------------------------------

    def parse_file(path)
      parse(path.read)
    end
  end
end
