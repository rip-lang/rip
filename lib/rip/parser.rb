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

    rule(:comment) { (str('#') >> (eol.absent? >> any).repeat.as(:comment)) >> eol.maybe }

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
      ancestors = surround_with('(', thing_list(class_literal | reference).as(:ancestors).maybe, ')')
      (class_keyword >> whitespaces? >> ancestors.maybe >> whitespaces? >> block).as(:class)
    end

    rule(:lambda_literal) do
      parameters = surround_with('(', thing_list(assignment | simple_reference.as(:reference)).as(:parameters), ')')
      (lambda_keyword >> whitespaces? >> parameters.maybe >> whitespaces? >> block).as(:lambda)
    end

    #---------------------------------------------

    rule(:if_condition) { if_keyword >> spaces? >> binary_condition }
    rule(:unless_condition) { unless_keyword >> spaces? >> binary_condition }

    # NOTE phrase is defined in Rip::Parsers::SimpleExpression and will be available when needed
    rule(:binary_condition) { surround_with('(', phrase.as(:binary_condition), ')') }

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

    #---------------------------------------------

    rule(:invocation) { regular_invocation | operator_invocation }
    rule(:regular_invocation) { ((lambda_literal | reference) >> surround_with('(', thing_list(object).as(:arguments), ')')).as(:invocation) }
    rule(:operator_invocation) { (object.as(:operand) >> spaces >> reference.as(:operator) >> spaces >> object.as(:argument)).as(:invocation) }

    # TODO consider multiple assignment
    # TODO rules for visibility (public, protected, private)
    rule(:assignment) { (reference >> spaces >> str('=') >> spaces >> expression.as(:value)).as(:assignment) }

    #---------------------------------------------

    # FIXME invocation instead of regular_invocation
    rule(:object) { (recursive_object | simple_object | structural_object | regular_invocation | reference) >> property.repeat.as(:property_chain) }

    rule(:property) { str('.') >> (regular_invocation | reference) }

    # TODO rules for system, date, time, datetime, version, units?
    rule(:simple_object) { numeric | character | string | regular_expression }

    rule(:recursive_object) { key_value_pair | range | hash_literal | list }

    rule(:structural_object) { class_literal | lambda_literal }

    #---------------------------------------------

    rule(:whitespace) { space | eol }
    rule(:whitespaces) { whitespace.repeat(1) }
    rule(:whitespaces?) { whitespaces.maybe }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:eol) { str("\r\n") | str("\n") | str("\r") }
    rule(:eols) { eol.repeat }

    rule(:expression_terminator) { str(';') | eol }
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
    rule(:lambda_keyword) { (str('->') | str('=>')).as(:lambda_keyword) }

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
    rule(:string) { symbol_string | single_quoted_string | double_quoted_string | here_doc }

    # FIXME should match most (all?) non-whitespace characters
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

    #rule(:system) { '`' ( !'`' . / '\`' )* '`' }

    #rule(:version) do
    #  dot = str('.')
    #  (str('v') >> integer.as(:major) >> dot >> integer.as(:minor) >> dot >> integer.as(:patch)).as(:version)
    #end

    #---------------------------------------------

    #rule(:datetime) { date >> str('T') >> time }

    #rule(:date) do
    #  dash = str('-')
    #  (digit.repeat(4, 4).as(:year) >> dash >> digit.repeat(2, 2).as(:month) >> dash >> digit.repeat(2, 2).as(:day)).as(:date)
    #end

    ## TODO make second optional
    ## TODO handle fractional seconds (optional) and time zone offset (optional)
    #rule(:time) do
    #  colon = str(':')
    #  (digit.repeat(2, 2).as(:hour) >> colon >> digit.repeat(2, 2).as(:minute) >> colon >> digit.repeat(2, 2).as(:second)).as(:time)
    #end

    #---------------------------------------------

    # TODO allow type restriction
    # FIXME allow more types to be used as the key
    rule(:key_value_pair) { (simple_object | reference).as(:key) >> spaces? >> str(':') >> spaces? >> object.as(:value) }

    rule(:range) do
      rangable_object = integer | character | reference
      rangable_object.as(:start) >> str('..') >> str('.').maybe.as(:exclusivity) >> rangable_object.as(:end)
    end

    # NOTE a hash is just a list with only key_value_pairs allowed in it
    # TODO allow type restriction (to be passed on to key value pairs and list)
    rule(:hash_literal) { surround_with('{', thing_list(key_value_pair | reference).as(:hash), '}') }

    # TODO allow type restriction
    rule(:list) { surround_with('[', thing_list(object).as(:list), ']') }

    #---------------------------------------------

    def parse_file(path)
      parse(path.read)
    end

    #---------------------------------------------

    # protected

    def block(body = statements)
      surround_with('{', body.as(:body), '}')
    end

    # NOTE see "Repetition and its Special Cases" note about #maybe versus #repeat(0, nil) at http://kschiess.github.com/parslet/parser.html
    def thing_list(thing, separator = ',')
      (thing >> (whitespaces? >> (separator.is_a?(String) ? str(separator) : separator) >> whitespaces? >> thing).repeat).repeat(0, nil)
    end

    def surround_with(left, center, right = left)
      str(left) >> whitespaces? >> center >> whitespaces? >> str(right)
    end
  end
end
