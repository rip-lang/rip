require 'parslet'
require 'pathname'

module Rip::Compiler
  class Parser < Parslet::Parser
    attr_reader :origin
    attr_reader :source_code

    def initialize(origin, source_code)
      @origin = origin
      @source_code = source_code
    end

    # NOTE shouldn't Rip::Compiler::AST create Rip::Nodes::Module?
    def syntax_tree
      location = Rip::Utilities::Location.new(origin, 0, 1, 1)
      expressions = Rip::Compiler::AST.new(origin).apply(parse_tree)
      _expressions = expressions.is_a?(String) ? [] : expressions
      body = Rip::Nodes::BlockBody.new(location, _expressions)
      Rip::Nodes::Module.new(location, body)
    end

    def parse_tree
      Rip::Compiler::ParseTreeNormalizer.new.apply(raw_parse_tree).tap do |reply|
        def reply.to_debug
          Rip::Utilities::ParseTreeDebugger.to_debug(self)
        end
      end
    end

    def raw_parse_tree
      ugly_tree = parse(source_code)
      collapse_atom(ugly_tree).tap do |reply|
        def reply.to_debug
          Rip::Utilities::ParseTreeDebugger.to_debug(self)
        end
      end
    end

    def collapse_atom(tree)
      case tree
      when Array
        tree.map { |t| collapse_atom(t) }
      when Hash
        _tree = tree.map do |key, value|
          [ key, collapse_atom(value) ]
        end
        reply = Hash[_tree]
        if reply.key?(:atom)
          reply[:atom].is_a?(Array) ? reply : reply[:atom]
        else
          reply
        end
      else tree
      end
    end


    root(:lines)


    rule(:whitespace) { space | line_break }
    rule(:whitespaces) { whitespace.repeat(1) }
    rule(:whitespaces?) { whitespaces.maybe }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:line_break) { str("\r\n") | str("\n") | str("\r") }
    rule(:line_breaks) { line_break.repeat(1) }
    rule(:line_breaks?) { line_breaks.maybe }


    rule(:expression_terminator) { semicolon | line_break }
    rule(:expression_terminator?) { expression_terminator.maybe }


    rule(:eof) { any.absent? }

    rule(:dot) { str('.') }
    rule(:comma) { str(',') }
    rule(:semicolon) { str(';') }
    rule(:colon) { str(':') }
    rule(:pound) { str('#') }
    rule(:underscore) { str('_') }
    rule(:equals) { str('=') }

    rule(:slash_back) { str('\\') }
    rule(:slash_forward) { str('/') }

    rule(:angled_open) { str('<') }
    rule(:angled_close) { str('>') }

    rule(:brace_open) { str('{') }
    rule(:brace_close) { str('}') }

    rule(:bracket_open) { str('[') }
    rule(:bracket_close) { str(']') }

    rule(:parenthesis_open) { str('(') }
    rule(:parenthesis_close) { str(')') }

    rule(:quote_single) { str('\'') }
    rule(:quote_double) { str('"') }
    rule(:backtick) { str('`') }


    rule(:lines) { line.repeat }
    rule(:line) { whitespaces | expression | comment }

    rule(:comment) { pound >> (line_break.absent? >> any).repeat.as(:comment) >> (line_break | eof) }

    rule(:expression) { expression_base >> spaces? >> expression_terminator? }

    rule(:expression_base) { (keyword >> spaces >> phrase.as(:payload)) | keyword | phrase }

    rule(:keyword) { %i[exit return throw].map { |kw| str(kw.to_s).as(kw) >> reference.absent? }.inject(:|) }


    rule(:phrase) { atom_5 }

    rule(:atom_5) { (atom_4 >> (expression_terminator.absent? >> operator_invocation).repeat).as(:atom) }
    rule(:operator_invocation) { (whitespaces >> reference.as(:operator) >> whitespaces >> atom_4.as(:argument)).as(:operator_invocation) }

    rule(:atom_4) { (atom_3 >> (expression_terminator.absent? >> assignment).repeat).as(:atom) }
    rule(:assignment) { (whitespaces >> equals.as(:location) >> whitespaces >> phrase.as(:rhs)).as(:assignment) }

    rule(:atom_3) { (atom_2 >> (expression_terminator.absent? >> key_value_pair).repeat).as(:atom) }
    rule(:key_value_pair) { (whitespaces? >> colon >> whitespaces? >> atom_2.as(:value)).as(:key_value_pair) }

    rule(:atom_2) { (atom_1 >> (expression_terminator.absent? >> range).repeat).as(:atom) }
    rule(:range) { (whitespaces? >> dot >> dot >> dot.maybe.as(:exclusivity) >> atom_1.as(:end)).as(:range) }

    rule(:atom_1) { (object >> (expression_terminator.absent? >> (regular_invocation | index_invocation | property)).repeat).as(:atom) }
    rule(:regular_invocation) { regular_invocation_arguments.as(:regular_invocation) }
    rule(:regular_invocation_arguments) { parenthesis_open.as(:location) >> whitespaces? >> csv(phrase).as(:arguments) >> whitespaces? >> parenthesis_close }
    rule(:index_invocation) { (bracket_open.as(:open) >> csv(phrase).as(:arguments) >> bracket_close.as(:close)).as(:index_invocation) }
    rule(:property) { dot >> property_name.as(:property_name) }
    rule(:property_name) { reference | (bracket_open >> bracket_close) }

    # https://github.com/kschiess/parslet/blob/master/example/capture.rb
    # TODO literals for heredoc
    # TODO literals for datetime, date, time, version (maybe)
    # TODO literals for unit
    rule(:object) do
      condition_block_sequence |
        exception_block_sequence |
        class_block |
        lambda_block |
        switch_block |
        number |
        character |
        string |
        regular_expression |
        map |
        list |
        reference |
        parenthesis_open >> phrase >> parenthesis_close
    end


    rule(:condition_block_sequence) { (if_block | unless_block) >> whitespaces? >> else_block.maybe }

    rule(:exception_block_sequence) { try_block >> (whitespaces? >> catch_block).repeat.as(:catch_blocks) >> whitespaces? >> finally_block.maybe }

    rule(:lambda_block) { (str('->').as(:dash_rocket) | str('=>').as(:fat_rocket)) >> spaces? >> parameters.maybe >> block_body }

    rule(:class_block) { str('class').as(:class) >> spaces? >> multiple_arguments.maybe >> block_body }
    rule(:case_block)  { str('case').as(:case)   >> spaces? >> multiple_arguments       >> block_body }

    rule(:switch_block) { str('switch').as(:switch) >> spaces? >> single_argument.maybe >> block_body_switch }
    rule(:catch_block)  { str('catch').as(:catch)   >> spaces? >> single_argument       >> block_body }

    rule(:if_block)     { (str('if').as(:if)         >> spaces? >> single_argument >> block_body).as(:if_block) }
    rule(:unless_block) { (str('unless').as(:unless) >> spaces? >> single_argument >> block_body).as(:unless_block) }

    rule(:try_block)     { (str('try').as(:try)         >> block_body).as(:try_block) }
    rule(:finally_block) { (str('finally').as(:finally) >> block_body).as(:finally_block) }
    rule(:else_block)    { (str('else').as(:else)       >> block_body).as(:else_block) }

    rule(:parameters) { parenthesis_open >> whitespaces? >> csv(optional_parameter | required_parameter).as(:parameters) >> whitespaces? >> parenthesis_close }
    rule(:required_parameter) { reference }
    rule(:optional_parameter) { reference.as(:lhs) >> whitespaces? >> equals.as(:location) >> whitespaces? >> phrase.as(:rhs) }

    rule(:multiple_arguments) { parenthesis_open >> whitespaces? >> csv(phrase).as(:arguments) >> whitespaces? >> parenthesis_close }
    rule(:single_argument) { parenthesis_open >> whitespaces? >> phrase.as(:argument) >> whitespaces? >> parenthesis_close }

    rule(:block_body) { whitespaces? >> brace_open.as(:location_body) >> whitespaces? >> lines.as(:body) >> whitespaces? >> brace_close }
    rule(:block_body_switch) { whitespaces? >> brace_open >> whitespaces? >> (case_block >> whitespaces?).repeat(1).as(:case_blocks) >> else_block.maybe.as(:else_block) >> whitespaces? >> brace_close }


    # WARNING order is important here: decimal must be before integer or the integral part of
    #   a decimal could be interpreted as a integer followed by a decimal starting with a dot
    rule(:number) { sign.maybe >> (decimal | integer) }

    rule(:decimal) { (digits.maybe >> dot >> digits).as(:decimal) }
    rule(:integer) { digits.as(:integer) }

    rule(:sign) { match['+-'].as(:sign) }

    rule(:digit) { match['0-9'] }
    rule(:digits) { digit.repeat(1) >> (underscore.maybe >> digit.repeat(1)).repeat }


    rule(:character) { backtick >> (escape_advanced | character_legal).as(:character) }
    rule(:character_legal) { digit | word_legal }


    rule(:escape_simple)   { escape_token_quote_single  | escape_token_slash_back }
    rule(:escape_regex)    { escape_token_slash_forward | escape_token_slash_back }
    rule(:escape_advanced) { escape_token_unicode       | escape_token_any }

    rule(:escape_token_quote_single)  { slash_back.as(:location) >> quote_single.as(:escaped_token) }
    rule(:escape_token_double)        { slash_back.as(:location) >> quote_double.as(:escaped_token) }
    rule(:escape_token_slash_back)    { slash_back.as(:location) >> slash_back.as(:escaped_token) }
    rule(:escape_token_slash_forward) { slash_back.as(:location) >> slash_forward.as(:escaped_token) }
    rule(:escape_token_unicode)       { slash_back.as(:location) >> str('u') >> match['0-9a-f'].repeat(4, 4).as(:escaped_token_unicode) }
    rule(:escape_token_any)           { slash_back.as(:location) >> any.as(:escaped_token) }


    rule(:string) { string_symbol | string_single | string_double }

    rule(:string_symbol) { colon >> (escape_simple | character_legal).as(:character).repeat(1).as(:string) }

    rule(:string_single) { string_parser(quote_single, escape_simple.as(:character)) }
    rule(:string_double) { string_parser(quote_double, escape_advanced.as(:character) | interpolation) }

    rule(:regular_expression) { string_parser(slash_forward, escape_regex.as(:character) | interpolation, :regex) }


    rule(:interpolation) { interpolation_start.as(:start) >> (interpolation_end.absent? >> line.repeat(1)).repeat.as(:interpolation) >> interpolation_end.as(:end) }
    rule(:interpolation_start) { pound >> brace_open }
    rule(:interpolation_end) { brace_close }


    rule(:reference) { (word | slash_forward).repeat(1).as(:reference) }

    rule(:word) { word_legal >> (word_legal | digit).repeat }
    rule(:word_legal) { match['^\d\s\`\'",.:;#\/\\()<>\[\]{}'] }


    rule(:map) { brace_open >> whitespaces? >> csv(phrase).as(:map) >> whitespaces? >> brace_close }

    rule(:list) { bracket_open >> whitespaces? >> csv(phrase).as(:list) >> whitespaces? >> bracket_close }


    protected

    # "borrowed" from http://jmettraux.wordpress.com/2011/05/11/parslet-and-json/
    def csv(value)
      _value = whitespaces? >> value >> whitespaces?
      (_value >> (comma >> _value).repeat).repeat(0, 1)
    end

    def string_parser(delimiter, inner_special, delimited_flag = :string)
      delimiter >> (delimiter.absent? >> (inner_special | any.as(:character))).repeat.as(delimited_flag) >> delimiter
    end
  end
end
