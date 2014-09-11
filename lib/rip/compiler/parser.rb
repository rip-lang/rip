require 'parslet'

module Rip::Compiler
  class Parser < Parslet::Parser
    attr_reader :origin
    attr_reader :source_code

    def initialize(origin, source_code)
      @origin = origin
      @source_code = source_code
    end

    def syntax_tree
      Rip::Compiler::AST.new(origin).apply(parse_tree)
    end

    def parse_tree
      Rip::Compiler::ParseTreeNormalizer.new.apply(raw_parse_tree).tap do |reply|
        def reply.to_debug
          Rip::Utilities::ParseTreeDebugger.to_debug(self)
        end
      end
    end

    def raw_parse_tree
      ugly_tree = begin
        parse(source_code)
      rescue Parslet::ParseFailed => e
        location = Rip::Utilities::Location.new(origin, e.cause.pos, *e.cause.source.line_and_column)
        raise Rip::Exceptions::SyntaxError.new(e.message, location, [], e.cause.ascii_tree)
      end

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


    root(:module)


    rule(:whitespace) { space | line_break | comment }
    rule(:whitespaces) { whitespace.repeat(1) }
    rule(:whitespaces?) { whitespaces.maybe }

    rule(:space) { str(' ') | str("\t") }
    rule(:spaces) { space.repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:line_break) { str("\r\n") | str("\n") | str("\r") }
    rule(:line_breaks) { line_break.repeat(1) }
    rule(:line_breaks?) { line_breaks.maybe }

    rule(:comment) { pound >> (line_break.absent? >> any).repeat >> (line_break | eof) }


    rule(:expression_terminator) { semicolon | line_break }
    rule(:expression_terminator?) { expression_terminator.maybe }


    rule(:eof) { any.absent? }

    rule(:dot) { str('.') }
    rule(:comma) { str(',') }
    rule(:semicolon) { str(';') }
    rule(:colon) { str(':') }
    rule(:pound) { str('#') }
    rule(:dash) { str('-') }
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


    rule(:module) { lines.as(:module) }
    rule(:lines) { line.repeat }
    rule(:line) { whitespaces | expression }

    rule(:expression) { expression_base >> spaces? >> expression_terminator? }

    rule(:expression_base) { (keyword >> spaces >> phrase.as(:payload)) | keyword | phrase }

    rule(:keyword) { %i[exit return throw].map { |kw| str(kw.to_s).as(kw) >> reference.absent? }.inject(:|) }


    rule(:phrase) { operator_invocation? }

    rule(:operator_invocation?) { (assignment? >> (expression_terminator.absent? >> operator_invocation).repeat).as(:atom) }
    rule(:operator_invocation) { (whitespaces >> property_name.as(:operator) >> whitespaces >> assignment?.as(:argument)).as(:operator_invocation) }

    rule(:assignment?) { (key_value_pair? >> (expression_terminator.absent? >> assignment).repeat).as(:atom) }
    rule(:assignment) { (whitespaces >> equals.as(:location) >> whitespaces >> phrase.as(:rhs)).as(:assignment) }

    rule(:key_value_pair?) { time | (range? >> (expression_terminator.absent? >> key_value_pair).repeat).as(:atom) }
    rule(:key_value_pair) { (whitespaces? >> colon.as(:location) >> whitespaces? >> range?.as(:value)).as(:key_value_pair) }

    rule(:range?) { (atom? >> (expression_terminator.absent? >> range).repeat).as(:atom) }
    rule(:range) { (whitespaces? >> dot.repeat(2, 2).as(:location) >> dot.maybe.as(:exclusivity) >> whitespaces? >> atom?.as(:end)).as(:range) }

    rule(:atom?) { (object >> (expression_terminator.absent? >> (regular_invocation | index_invocation | property)).repeat).as(:atom) }
    rule(:regular_invocation) { (parenthesis_open.as(:location) >> whitespaces? >> csv(phrase).as(:arguments) >> whitespaces? >> parenthesis_close).as(:regular_invocation) }
    rule(:index_invocation)   { (bracket_open.as(:open)         >> whitespaces? >> csv(phrase).as(:arguments) >> whitespaces? >> bracket_close.as(:close)).as(:index_invocation) }

    rule(:property) { whitespaces? >> dot.as(:location) >> property_name.as(:property_name) }
    rule(:property_name) do
      word |
        str('/%') |
        str('/') |
        str('<=>') |
        str('<=') |
        str('<').repeat(1, 2) |
        str('>=') |
        str('>').repeat(1, 2) |
        str('[]')
    end

    # TODO literals for unit
    # TODO literals for version (maybe)
    rule(:object) do
      condition_block_sequence |
        exception_block_sequence |
        class_block |
        lambda_block |
        overload_block |
        switch_block |
        datetime |
        date |
        number |
        character |
        string |
        regular_expression |
        heredoc |
        map |
        list |
        reference |
        parenthesis_open >> whitespaces? >> phrase >> whitespaces? >> parenthesis_close
    end


    rule(:reference) { word.as(:reference) }

    rule(:word) { word_legal >> (word_legal | digit).repeat }
    rule(:word_legal) { match['^\d\s\`\'",.:;#\/\\()<>\[\]{}'] }


    rule(:condition_block_sequence) { if_block >> whitespaces? >> else_block.maybe }

    rule(:exception_block_sequence) { try_block >> (whitespaces? >> catch_block).repeat.as(:catch_blocks) >> whitespaces? >> finally_block.maybe }

    rule(:lambda_block)   { str('=>').as(:fat_rocket) >> spaces? >> block_body_lambda }

    rule(:overload_block) { str('->').as(:dash_rocket) >> spaces? >> parameters.maybe >> block_body }

    rule(:class_block) { str('class').as(:class) >> spaces? >> multiple_arguments.maybe >> block_body }
    rule(:case_block)  { str('case').as(:case)   >> spaces? >> multiple_arguments       >> block_body }

    rule(:switch_block) { str('switch').as(:switch) >> spaces? >> single_argument.maybe >> block_body_switch }
    rule(:catch_block)  { str('catch').as(:catch)   >> spaces? >> single_argument       >> block_body }

    rule(:if_block)     { (str('if').as(:if) >> spaces? >> single_argument >> block_body).as(:if_block) }

    rule(:try_block)     { (str('try').as(:try)         >> block_body).as(:try_block) }
    rule(:finally_block) { (str('finally').as(:finally) >> block_body).as(:finally_block) }
    rule(:else_block)    { (str('else').as(:else)       >> block_body).as(:else_block) }

    rule(:parameters) { parenthesis_open >> whitespaces? >> csv(optional_parameter | required_parameter).as(:parameters) >> whitespaces? >> parenthesis_close }
    rule(:required_parameter) { word.as(:parameter) >> parameter_type_argument.maybe }
    rule(:optional_parameter) { word.as(:parameter) >> parameter_type_argument.maybe >> whitespaces? >> equals >> whitespaces? >> phrase.as(:default_expression) }
    rule(:parameter_type_argument) { angled_open >> spaces? >> phrase.as(:type_argument) >> spaces? >> angled_close }

    rule(:multiple_arguments) { parenthesis_open >> whitespaces? >> csv(phrase).as(:arguments) >> whitespaces? >> parenthesis_close }
    rule(:single_argument) { parenthesis_open >> whitespaces? >> phrase.as(:argument) >> whitespaces? >> parenthesis_close }

    rule(:block_body) { whitespaces? >> brace_open.as(:location_body) >> whitespaces? >> lines.as(:body) >> whitespaces? >> brace_close }
    rule(:block_body_switch) { whitespaces? >> brace_open >> whitespaces? >> (case_block >> whitespaces?).repeat(1).as(:case_blocks) >> else_block.maybe.as(:else_block) >> whitespaces? >> brace_close }
    rule(:block_body_lambda) { whitespaces? >> brace_open.as(:location_body) >> whitespaces? >> (overload_block >> whitespaces?).repeat(1).as(:overload_blocks) >> whitespaces? >> brace_close }


    rule(:datetime) { date.as(:date) >> str('T') >> time.as(:time) }

    rule(:date) { digit.repeat(4, 4).as(:year) >> dash >> digit.repeat(2, 2).as(:month) >> dash >> digit.repeat(2, 2).as(:day) }

    rule(:time) do
      (digit.repeat(2, 2).as(:hour) >> colon >> digit.repeat(2, 2).as(:minute) >> colon >> digit.repeat(2, 2).as(:second)) >>
        (dot >> digits.as(:sub_second)).maybe >>
        (sign >> digit.repeat(2, 2).as(:hour) >> digit.repeat(2, 2).as(:minute)).as(:offset).maybe
    end


    # WARNING order is important here: decimal must be before integer or the integral part of
    #   a decimal could be interpreted as a integer followed by a decimal starting with a dot
    rule(:number) { sign.maybe >> (decimal | integer) }

    rule(:decimal) { (digits >> dot >> digits).as(:decimal) }
    rule(:integer) { digits.as(:integer) }

    rule(:sign) { match['+-'].as(:sign) }

    rule(:digit) { match['0-9'] }
    rule(:digits) { digit.repeat(1) >> (underscore.maybe >> digit.repeat(1)).repeat }


    rule(:character) { backtick.as(:location) >> (escape_advanced | character_legal).as(:character) }
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

    rule(:string_symbol) { colon.as(:location) >> (escape_simple | character_legal).as(:character).repeat(1).as(:string) }

    rule(:string_single) { string_parser(quote_single, escape_simple.as(:character)) }
    rule(:string_double) { string_parser(quote_double, escape_advanced.as(:character) | interpolation) }

    rule(:regular_expression) { string_parser(slash_forward, escape_regex.as(:character) | interpolation(:interpolation_regex), :regex) }


    # https://github.com/kschiess/parslet/blob/master/example/capture.rb
    rule(:heredoc) do
      scope { heredoc_start >> heredoc_content.as(:string) >> heredoc_end }
    end

    rule(:heredoc_start) { angled_open.repeat(2, 2).as(:location) >> heredoc_label >> line_break }
    rule(:heredoc_label) { match['A-Z_'].repeat(1).capture(:heredoc_label) }

    rule(:heredoc_content) { (heredoc_end.absent? >> heredoc_line).repeat }
    rule(:heredoc_line) { (line_break.absent? >> heredoc_content_any).repeat >> line_break.as(:line_break) }
    rule(:heredoc_content_any) { escape_advanced.as(:character) | interpolation | any.as(:character) }

    rule(:heredoc_end) do
      dynamic { |source, context| spaces? >> str(context.captures[:heredoc_label]) >> (line_break | eof) }
    end


    rule(:map) { brace_open.as(:location) >> whitespaces? >> csv(phrase).as(:map) >> whitespaces? >> brace_close }

    rule(:list) { bracket_open.as(:location) >> whitespaces? >> csv(phrase).as(:list) >> whitespaces? >> bracket_close }


    protected

    # "borrowed" from http://jmettraux.wordpress.com/2011/05/11/parslet-and-json/
    def csv(value)
      _value = whitespaces? >> value >> whitespaces?
      (_value >> (comma >> _value).repeat).repeat(0, 1)
    end

    def interpolation(target = :interpolation)
      (pound >> brace_open).as(:start) >> (brace_close.absent? >> line.repeat(1)).repeat.as(target) >> brace_close.as(:end)
    end

    def string_parser(delimiter, inner_special, delimited_flag = :string)
      delimiter.as(:location) >> (delimiter.absent? >> (inner_special | any.as(:character))).repeat.as(delimited_flag) >> delimiter
    end
  end
end
