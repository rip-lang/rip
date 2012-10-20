require 'parslet'
require 'pathname'

require 'rip/keywords'

module Rip
  class Parser < Parslet::Parser
    root(:statements)

    # statement
    #   comment
    #   expression (literal, invocation or reference eg: 2 + 2, full_name())
    #   assignment (reference = expression eg: answer = 2 + 2, name = full_name())
    #   block (if, unless, switch, case, try, class, lambda et cetera)
    #   (expression | assignment | block) comment

    # in rip everything looks like one of the following
    #   comment
    #   string, number, regular expression etc
    #   list, map
    #   block
    #   reference
    #   reference followed by parameter list

    rule(:statement) { whitespaces? >> (comment | (expression >> spaces? >> comment.maybe)) >> whitespaces? }
    rule(:statements) { thing_list(statement, whitespaces?) }

    rule(:comment) { (pound >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    rule(:expression) { block_expression | simple_expression }

    #---------------------------------------------

    # NOTE anything that might be followed by an expression terminator
    rule(:simple_expression) do
      (((postfix | keyword | phrase) >> (spaces >> postfix).maybe) | postfix) >> spaces? >> expression_terminator?
    end

    # TODO allow parenthesis around phrase to arbitrary levels
    rule(:phrase) { (keyword | postfix).absent? >> (invocation | object) }

    rule(:postfix) do
      postfix_tail = spaces >> maybe_parens(phrase.as(:postfix_argument))
      (if_keyword >> postfix_tail).as(:if_postfix) | (unless_keyword >> postfix_tail).as(:unless_postfix) | (keyword >> postfix_tail).as(:postfix)
    end

    #---------------------------------------------

    rule(:parameters) { parens(comma_list(invocation | object).as(:parameters)) }

    # NOTE anything that should not be followed by an expression terminator
    rule(:block_expression) do
      block_body = surround_with(brace_open, statements.as(:body), brace_close)
      (keyword >> whitespaces? >> parameters.maybe >> whitespaces? >> block_body).as(:block)
    end

    #---------------------------------------------

    rule(:invocation) { regular_invocation | operator_invocation }

    rule(:regular_invocation) { ((block_expression | reference) >> parens(comma_list(object).as(:arguments))).as(:invocation) }

    # NOTE assignments are parsed as operator invocation
    # TODO consider multiple assignment
    # TODO rules for visibility (public, protected, private)
    rule(:operator_invocation) { (object.as(:operand) >> spaces >> reference.as(:operator) >> spaces >> object.as(:argument)).as(:invocation) }

    #---------------------------------------------

    # FIXME invocation instead of regular_invocation
    rule(:object) { (block_expression | recursive_object | simple_object | regular_invocation | reference) >> property.repeat.as(:property_chain) }

    rule(:property) { dot >> (regular_invocation | reference) }

    # TODO rules for system, date, time, datetime, version, units?
    rule(:simple_object) { numeric | character | string | regular_expression }

    rule(:recursive_object) { key_value_pair | range | hash_literal | list }

    #---------------------------------------------

    rule(:pound) { str('#') }

    rule(:dot) { str('.') }
    rule(:comma) { str(',') }

    rule(:equals) { str('=') }
    rule(:colon) { str(':') }
    rule(:semicolon) { str(';') }

    rule(:dash) { str('-') }
    rule(:underscore) { str('_') }
    rule(:slash_forward) { str('/') }

    rule(:dash_rocket) { str('->') }
    rule(:fat_rocket) { str('=>') }

    rule(:backtick) { str('`') }
    rule(:quote) { str("'") }
    rule(:double_quote) { str('"') }

    rule(:brace_open) { str('{') }
    rule(:brace_close) { str('}') }

    rule(:bracket_open) { str('[') }
    rule(:bracket_close) { str(']') }

    rule(:parenthesis_open) { str('(') }
    rule(:parenthesis_close) { str(')') }

    rule(:angled_open) { str('<') }
    rule(:angled_closed) { str('>') }

    #---------------------------------------------

    rule(:whitespace) { space | eol }
    rule(:whitespaces) { whitespace.repeat(1) }
    rule(:whitespaces?) { whitespaces.maybe }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:eol) { str("\r\n") | str("\n") | str("\r") }
    rule(:eols) { eol.repeat }

    rule(:expression_terminator) { semicolon | eol }
    rule(:expression_terminator?) { expression_terminator.maybe }

    #---------------------------------------------

    Rip::Keywords.all.each do |keyword|
      rule(keyword.rule) { str(keyword.keyword).as(keyword.name) }
    end

    rule(:keyword) do
      keyword_atoms = Rip::Keywords.all.map { |keyword| send(keyword.rule) }
      keyword_atoms.inject(keyword_atoms.pop) do |memo, keyword|
        memo | keyword
      end
    end

    #---------------------------------------------

    # http://www.rubular.com/r/sTue8ePXW9
    rule(:reference_legal) { match['^.,;:\d\s()\[\]{}'] }

    rule(:reference) { (reference_legal.repeat(1) >> (reference_legal | digit).repeat).as(:reference) }

    #---------------------------------------------

    # WARNING order is important here: decimal must be before integer or the integral part of a decimal could be interpreted as a integer followed by a decimal starting with a dot
    rule(:numeric) { sign.maybe >> (decimal | integer) }

    rule(:decimal) { (digits.maybe >> dot >> digits).as(:decimal) }

    rule(:integer) { digits.as(:integer) }

    rule(:sign) { match['+-'].as(:sign) }

    rule(:digit) { match['0-9'] }

    # allow _ to be used to group digits ( 3_423_752 )
    # _ may not come first or last
    rule(:digits) { digit.repeat(1) >> (underscore.maybe >> digit.repeat(1)).repeat }

    #---------------------------------------------

    rule(:character_legal) { digit | reference_legal }
    rule(:character) { backtick >> character_legal.as(:character) }

    #---------------------------------------------

    # NOTE a string is just a list with characters allowed in it
    rule(:string) { symbol_string | single_quoted_string | double_quoted_string | here_doc }

    rule(:symbol_string) { colon >> character_legal.repeat(1).as(:string) }

    rule(:single_quoted_string) { quote >> (quote.absent? >> any).repeat.as(:string) >> quote }

    rule(:double_quoted_string) { double_quote >> (double_quote.absent? >> any).repeat.as(:string) >> double_quote }

    rule(:here_doc) do
      label = match['A-Z_'].repeat(1)
      start = angled_open.repeat(2, 2) >> label.as(:here_doc_start) >> eol
      content = (label.absent? >> any).repeat.as(:string)
      finish = label.as(:here_doc_end) >> eol.maybe
      start >> content >> finish
    end

    #---------------------------------------------

    # TODO expand regular expression pattern
    rule(:regular_expression) { slash_forward >> (slash_forward.absent? >> any).repeat.as(:regex) >> slash_forward }

    # rule(:system) { backtick ( !backtick . / '\`' )* backtick }

    # rule(:version) do
    #   (str('v') >> integer.as(:major) >> dot >> integer.as(:minor) >> dot >> integer.as(:patch)).as(:version)
    # end

    #---------------------------------------------

    #rule(:datetime) { date >> str('T') >> time }

    #rule(:date) do
    #  (digit.repeat(4, 4).as(:year) >> dash >> digit.repeat(2, 2).as(:month) >> dash >> digit.repeat(2, 2).as(:day)).as(:date)
    #end

    ## TODO make second optional
    ## TODO handle fractional seconds (optional) and time zone offset (optional)
    #rule(:time) do
    #  (digit.repeat(2, 2).as(:hour) >> colon >> digit.repeat(2, 2).as(:minute) >> colon >> digit.repeat(2, 2).as(:second)).as(:time)
    #end

    #---------------------------------------------

    # TODO allow type restriction
    # FIXME allow more types to be used as the key
    rule(:key_value_pair) { (simple_object | reference).as(:key) >> spaces? >> colon >> spaces? >> object.as(:value) }

    rule(:range) do
      rangable_object = integer | character | reference
      rangable_object.as(:start) >> dot >> dot >> dot.maybe.as(:exclusivity) >> rangable_object.as(:end)
    end

    # NOTE a hash is just a list with only key_value_pairs allowed in it
    # TODO allow type restriction (to be passed on to key value pairs and list)
    rule(:hash_literal) { surround_with(brace_open, comma_list(key_value_pair | reference).as(:hash), brace_close) }

    # TODO allow type restriction
    rule(:list) { surround_with(bracket_open, comma_list(phrase).as(:list), bracket_close) }

    #---------------------------------------------

    def parse_file(path)
      parse(path.read)
    end

    #---------------------------------------------

    protected

    def parens(center)
      surround_with(parenthesis_open, center, parenthesis_close)
    end

    def maybe_parens(center)
      maybe_surround_with(parenthesis_open, center, parenthesis_close)
    end

    def surround_with(left, center, right = left)
      left >> whitespaces? >> center >> whitespaces? >> right
    end

    def maybe_surround_with(left, center, right = left)
      surround_with(left, center, right) | center
    end

    def comma_list(thing)
      thing_list thing, comma
    end

    # NOTE see "Repetition and its Special Cases" note about #maybe versus #repeat(0, nil) at http://kschiess.github.com/parslet/parser.html
    def thing_list(thing, separator)
      (thing >> (whitespaces? >> separator >> whitespaces? >> thing).repeat).repeat
    end
  end
end
