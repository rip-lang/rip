require 'parslet'
require 'pathname'

module Rip
  class Parser < Parslet::Parser
    root(:statements)

    # statement
    #   comment
    #   expression (literal, invocation or reference eg: 2 + 2, full_name())
    #   assignment (reference = expression eg: answer = 2 + 2, name = full_name())
    #   block (if, unless, switch, case, try)
    #   (expression | assignment | block) comment

    # in rip everything looks like one of the following
    #   comment
    #   string, number, regular expression etc
    #   list, map
    #   block
    #   reference
    #   reference followed by parameter
    #   reference followed by parameter list

    rule(:statement) { (comment | expression) >> spaces? >> comment.maybe }
    rule(:statements) { thing_list(statement, whitespaces?) }

    rule(:comment) { (pound >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

    rule(:expression) { (simple_expression | block_expression) }

    #---------------------------------------------

    # NOTE anything that might be followed by an expression terminator
    rule(:simple_expression) do
      ((exiter >> spaces >> phrase) | exiter | phrase) >> (spaces >> postfix).maybe >> spaces? >> expression_terminator?
    end

    # TODO allow parenthesis around phrase to arbitrary levels
    rule(:phrase) { (exiter | postfix).absent? >> (assignment | invocation | object) }

    [:if, :unless].each do |cond|
      name = "#{cond}_postfix".to_sym
      rule(name) { send("#{cond}_condition").as(name) }
    end
    rule(:postfix) { (if_postfix | unless_postfix) }

    #---------------------------------------------

    rule(:class_literal) do
      ancestors = parens(comma_list(class_literal | reference).as(:ancestors).maybe)
      (class_keyword >> whitespaces? >> ancestors.maybe >> whitespaces? >> block).as(:class)
    end

    rule(:lambda_literal) do
      parameters = parens(comma_list(assignment | simple_reference.as(:reference)).as(:parameters))
      (lambda_keyword >> whitespaces? >> parameters.maybe >> whitespaces? >> block).as(:lambda)
    end

    #---------------------------------------------

    rule(:if_condition) { if_keyword >> spaces? >> binary_condition }
    rule(:unless_condition) { unless_keyword >> spaces? >> binary_condition }

    # NOTE phrase is defined in Rip::Parsers::SimpleExpression and will be available when needed
    rule(:binary_condition) { parens(phrase.as(:binary_condition)) }

    #---------------------------------------------

    # NOTE anything that should not be followed by an expression terminator
    # TODO rule for loop_block (maybe)
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
      switch_test = parens(object.as(:switch_test).maybe)
      cases = case_block.repeat(1) >> whitespaces? >> else_block.maybe
      (switch_keyword >> spaces? >> switch_test.maybe >> spaces? >> block(cases)).as(:switch)
    end

    rule(:case_block) do
      case_qualifiers = parens(comma_list(object).as(:case_qualifiers).maybe)
      (case_keyword >> whitespaces? >> case_qualifiers.maybe >> whitespaces? >> block).as(:case)
    end

    #---------------------------------------------

    rule(:exception_handling) do
      try_block = (try_keyword >> whitespaces? >> block).as(:try)
      catch_block = (catch_keyword >> whitespaces? >> parens(key_value_pair) >> whitespaces? >> block).as(:catch)
      finally = (finally_keyword >> whitespaces? >> block).as(:finally)

      (try_block >> whitespaces? >> catch_block.repeat(1) >> whitespaces? >> finally.maybe).as(:exception_handling)
    end

    #---------------------------------------------

    rule(:invocation) { regular_invocation | operator_invocation }
    rule(:regular_invocation) { ((lambda_literal | reference) >> parens(comma_list(object).as(:arguments))).as(:invocation) }
    rule(:operator_invocation) { (object.as(:operand) >> spaces >> reference.as(:operator) >> spaces >> object.as(:argument)).as(:invocation) }

    # TODO consider multiple assignment
    # TODO rules for visibility (public, protected, private)
    rule(:assignment) { (reference >> spaces >> equals >> spaces >> expression.as(:value)).as(:assignment) }

    #---------------------------------------------

    # FIXME invocation instead of regular_invocation
    rule(:object) { (recursive_object | simple_object | structural_object | regular_invocation | reference) >> property.repeat.as(:property_chain) }

    rule(:property) { dot >> (regular_invocation | reference) }

    # TODO rules for system, date, time, datetime, version, units?
    rule(:simple_object) { numeric | character | string | regular_expression }

    rule(:recursive_object) { key_value_pair | range | hash_literal | list }

    rule(:structural_object) { class_literal | lambda_literal }

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

    def self.make_keywords(*keywords)
      keywords.each do |keyword|
        name = "#{keyword}_keyword".to_sym
        rule(name) { str(keyword).as(name) }
      end
    end

    rule(:keyword) { object_keyword | conditional_keyword | exit_keyword | exception_keyword | reserved_keyword }

    rule(:object_keyword) { class_keyword | lambda_keyword }

    make_keywords :class
    rule(:lambda_keyword) { (dash_rocket | fat_rocket).as(:lambda_keyword) }

    rule(:conditional_keyword) { if_keyword | unless_keyword | switch_keyword | case_keyword | else_keyword }
    make_keywords :if, :unless, :switch, :case, :else

    rule(:exiter) { exit_keyword | return_keyword | throw_keyword | break_keyword | next_keyword }
    make_keywords :exit, :return, :throw, :break, :next

    rule(:exception_keyword) { try_keyword | catch_keyword | finally_keyword }
    make_keywords :try, :catch, :finally

    rule(:reserved_keyword) { from_keyword | as_keyword | join_keyword | union_keyword | on_keyword | where_keyword | order_keyword | select_keyword | limit_keyword | take_keyword }
    make_keywords :from, :as, :join, :union, :on, :where, :order, :select, :limit, :take

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

    # FIXME should match any single printable unicode character
    rule(:character) { backtick >> match['0-9a-zA-Z_'].as(:character) }

    #---------------------------------------------

    # NOTE a string is just a list with characters allowed in it
    rule(:string) { symbol_string | single_quoted_string | double_quoted_string | here_doc }

    # FIXME should match most (all?) non-whitespace characters
    rule(:symbol_string) { colon >> match['a-zA-Z_'].repeat(1).as(:string) }

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

    #rule(:system) { backtick ( !backtick . / '\`' )* backtick }

    #rule(:version) do
    #  (str('v') >> integer.as(:major) >> dot >> integer.as(:minor) >> dot >> integer.as(:patch)).as(:version)
    #end

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
    rule(:list) { surround_with(bracket_open, comma_list(object).as(:list), bracket_close) }

    #---------------------------------------------

    def parse_file(path)
      parse(path.read)
    end

    #---------------------------------------------

    # protected

    def block(body = statements)
      surround_with(brace_open, body.as(:body), brace_close)
    end

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
