# encoding: utf-8

require 'spec_helper'

describe Rip::Parser do
  context 'some basics' do
    let(:empty) { parser.parse_file(samples_path + 'empty.rip') }
    let(:comment) { parser.comment.parse('# this is a comment') }

    it 'parses an empty file' do
      expect(empty).to eq('')
    end

    it 'recognizes comments' do
      expect(comment[:comment]).to eq(' this is a comment')
    end

    it 'recognizes various whitespace sequences' do
      {
        [' ', "\t", "\r", "\n", "\r\n"] => :whitespace,
        [' ', "\t\t"]                   => :whitespaces,
        ['', "\n", "\t\r"]              => :whitespaces?,
        [' ', "\t"]                     => :space,
        [' ', "\t\t", "  \t  \t  "]     => :spaces,
        ['', ' ', "  \t  \t  "]         => :spaces?,
        ["\n", "\r", "\r\n"]            => :eol,
        ['', "\n", "\r\r"]              => :eols
      }.each do |whitespaces, method|
        space_parser = parser.send(method)
        whitespaces.each do |space|
          expect(space_parser.parse(space)).to eq(space)
        end
      end
    end
  end

  describe '#reference' do
    let(:assignment) { parser.assignment.parse('favorite_language = :rip') }

    it 'recognizes valid references' do
      [
        'name',
        'Person',
        '==',
        'save!',
        'valid?',
        'long_ref-name',
        '*/-+<>&$~%',
        'one_9',
        'É¹ÇÊ‡É¹oÔ€uÉlâˆ€â„¢'
      ].each do |reference|
        expect(parser.reference.parse(reference)[:reference]).to eq(reference)
      end
    end

    it 'skips invalid references' do
      [
        'one.two',
        '999',
        '6teen',
        'rip rocks',
        'key:value'
      ].each do |reference|
        expect do
          parser.reference.parse(reference)
        end.to raise_error(Parslet::ParseFailed) # Rip::ParseError
      end
    end

    it 'recognizes special references' do
      expect(parser.reference.parse('nilly')[:reference]).to eq('nilly')
      expect(parser.reference.parse('nil')[:reference]).to eq('nil')
      expect(parser.reference.parse('true')[:reference]).to eq('true')
      expect(parser.reference.parse('false')[:reference]).to eq('false')
      expect(parser.reference.parse('Kernel')[:reference]).to eq('Kernel')
    end

    it 'assigns to a reference' do
      expect(assignment[:assignment][:reference]).to eq('favorite_language')
      expect(assignment[:assignment][:value][:string]).to eq('rip')
    end
  end

  describe 'parenthesis' do
    let(:parens) { parser.expression.parse('((((((l((1 + (((2 - 3)))))))))))') }

    # it 'recognizes anything surrounded by parenthesis', :failing do
    #   puts; puts "parens => #{parens.inspect}"
    #   expect(parens[:invocation][:reference]).to eq('l')
    #   expect(parens[:invocation][:parameters][0][:operator_invocation][:operand]).to eq('1')
    #   expect(parens[:invocation][:parameters][0][:operator_invocation][:operator]).to eq('+')
    #   expect(parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:operand]).to eq('2')
    #   expect(parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:operator]).to eq('-')
    #   expect(parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:argument]).to eq('3')
    # end
  end

  describe 'property chains' do
    let(:chain_property) { parser.object.parse('0.one.two.three') }
    let(:change_invocation) { parser.object.parse('zero().one().two().three()') }
    let(:chain_property_invocation) { parser.object.parse('0.one().two.three()') }
    let(:operator_chain) { parser.object.parse('(1 - 2).zero?()') }

    it 'recognizes property chains' do
      expect(chain_property[:integer]).to eq('0')
      expect(chain_property[:property_chain][0][:reference]).to eq('one')
      expect(chain_property[:property_chain][1][:reference]).to eq('two')
      expect(chain_property[:property_chain][2][:reference]).to eq('three')
    end

    it 'recognizes property chains with invocations' do
      expect(change_invocation[:invocation][:reference]).to eq('zero')
      expect(change_invocation[:property_chain][0][:invocation][:reference]).to eq('one')
      expect(change_invocation[:property_chain][1][:invocation][:reference]).to eq('two')
      expect(change_invocation[:property_chain][2][:invocation][:reference]).to eq('three')
    end

    # it 'recognizes chaining with properies and invocations', :failing do
    #   puts; puts "chain_property_invocation => #{chain_property_invocation.inspect}"
    #   expect(chain_property_invocation[:integer]).to eq('0')
    #   expect(chain_property_invocation[:invocation][:reference]).to eq('one')
    #   expect(chain_property_invocation[:invocation][:parameters]).to eq([])
    #   expect(chain_property_invocation[:invocation][:property][:reference]).to eq('two')
    #   expect(chain_property_invocation[:invocation][:property][:invocation][:reference]).to eq('three')
    #   expect(chain_property_invocation[:invocation][:property][:invocation][:parameters]).to eq([])
    #   expect(chain_property_invocation[:invocation][:property][:invocation][:property]).to be_nil
    # end

    # it 'recognizes chaining off opererators', :failing do
    #   puts; puts "operator_chain => #{operator_chain.inspect}"
    #   expect(operator_chain[:operator_invocation][:operand]).to eq('1')
    #   expect(operator_chain[:operator_invocation][:operator]).to eq('-')
    #   expect(operator_chain[:operator_invocation][:argument]).to eq('2')
    #   expect(operator_chain[:operator_invocation][:invocation][:reference]).to eq('zero')
    #   expect(operator_chain[:operator_invocation][:invocation][:parameters]).to eq([])
    #   expect(operator_chain[:operator_invocation][:invocation][:property]).to be_nil
    # end
  end

  describe '#block_expression' do
    context 'parameters' do
      let(:block_empty) { parser.block_expression.parse('-> {}') }
      let(:block_empty_parens) { parser.block_expression.parse('class () {}') }

      let(:block_parameter) { parser.block_expression.parse('unless (:name) {}') }
      let(:block_paramter_default) { parser.block_expression.parse('-> (name = :rip) {}') }
      let(:block_multiple_parameters) { parser.block_expression.parse('case (one, two) {}') }
      let(:block_parameter_parameter_default) { parser.block_expression.parse('=> (platform, name = :rip) {}') }
      let(:block_block_parameter) { parser.block_expression.parse('class (class () {}) {}') }

      it 'recognizes empty blocks' do
        expect(block_empty[:block][:lambda_dash]).to eq('->')
        expect(block_empty[:block][:body]).to eq([])

        expect(block_empty_parens[:block][:class]).to eq('class')
        expect(block_empty_parens[:block][:body]).to eq([])
      end

      it 'recognizes blocks with parameter' do
        expect(block_parameter[:block][:unless]).to eq('unless')
        expect(block_parameter[:block][:parameters].count).to eq(1)
        expect(block_parameter[:block][:parameters].first[:string]).to eq('name')
      end

      it 'recognizes blocks with default parameter' do
        expect(block_paramter_default[:block][:parameters].count).to eq(1)
        expect(block_paramter_default[:block][:parameters].first[:assignment][:reference]).to eq('name')
        expect(block_paramter_default[:block][:parameters].first[:assignment][:value][:string]).to eq('rip')
      end

      it 'recognizes blocks with multiple parameters' do
        expect(block_multiple_parameters[:block][:parameters].count).to eq(2)
        expect(block_multiple_parameters[:block][:parameters].first[:reference]).to eq('one')
        expect(block_multiple_parameters[:block][:parameters].last[:reference]).to eq('two')
      end

      it 'recognizes blocks with parameter and default parameter' do
        expect(block_parameter_parameter_default[:block][:parameters].count).to eq(2)
        expect(block_parameter_parameter_default[:block][:parameters].first[:reference]).to eq('platform')
        expect(block_parameter_parameter_default[:block][:parameters].last[:assignment][:reference]).to eq('name')
      end

      it 'recognizes blocks with block parameters' do
        expect(block_block_parameter[:block][:class]).to eq('class')
        expect(block_block_parameter[:block][:parameters].count).to eq(1)
        expect(block_block_parameter[:block][:parameters].first[:block][:class]).to eq('class')
      end
    end

    context 'body' do
      let(:block_comment) { parser.block_expression.parse(<<-RIP.strip)[:block][:body].first }
                                                          if (true) {
                                                            # comment
                                                          }
                                                          RIP

      let(:block_reference) { parser.block_expression.parse('if (true) { name }')[:block][:body].first }
      let(:block_assignment) { parser.block_expression.parse('if (true) { x = :y }')[:block][:body].first }
      let(:block_invocation) { parser.block_expression.parse('if (true) { run!() }')[:block][:body].first }
      let(:block_invocation_operator) { parser.block_expression.parse('if (true) { steam will :rise }')[:block][:body].first }
      let(:block_literal) { parser.block_expression.parse('if (true) { `3 }')[:block][:body].first }

      it 'recognizes comments inside blocks' do
        expect(block_comment[:comment]).to eq(' comment')
      end

      it 'recognizes references inside blocks' do
        expect(block_reference[:reference]).to eq('name')
      end

      it 'recognizes assignments inside blocks' do
        expect(block_assignment[:assignment][:reference]).to eq('x')
        expect(block_assignment[:assignment][:value][:string]).to eq('y')
      end

      it 'recognizes invocations inside blocks' do
        expect(block_invocation[:invocation][:reference]).to eq('run!')
        expect(block_invocation[:invocation][:arguments]).to eq([])
      end

      it 'recognizes operator invocations inside blocks' do
        expect(block_invocation_operator[:invocation][:operand][:reference]).to eq('steam')
        expect(block_invocation_operator[:invocation][:operator][:reference]).to eq('will')
        expect(block_invocation_operator[:invocation][:argument][:string]).to eq('rise')
      end

      it 'recognizes literals inside blocks' do
        expect(block_literal[:character]).to eq('3')
      end
    end
  end

  describe '#simple_expression' do
    let(:keyword) { parser.simple_expression.parse('return;') }
    let(:postfix_postfix) { parser.simple_expression.parse('exit 1 if (:error)') }
    let(:postfix) { parser.simple_expression.parse('exit 0') }
    let(:postfix_parens) { parser.simple_expression.parse('exit (0)') }
    let(:postfix_if) { parser.simple_expression.parse('if (true);') }
    let(:postfix_unless) { parser.simple_expression.parse('unless false') }
    let(:keyword_postfix_a) { parser.simple_expression.parse('return unless (false);') }
    let(:keyword_postfix_b) { parser.simple_expression.parse('nil if (empty());') }
    let(:list) { parser.simple_expression.parse('[]') }

    it 'recognizes keyword' do
      expect(keyword[:return]).to eq('return')
    end

    it 'recognizes postfix followed by postfix' do
      expect(postfix_postfix[:postfix][:exit]).to eq('exit')
      expect(postfix_postfix[:postfix][:postfix_argument][:integer]).to eq('1')
      expect(postfix_postfix[:if_postfix][:postfix_argument][:string]).to eq('error')
    end

    it 'recognizes postfix' do
      expect(postfix[:postfix][:exit]).to eq('exit')
      expect(postfix[:postfix][:postfix_argument][:integer]).to eq('0')
    end

    it 'recognizes postfix with parenthesis around argument' do
      expect(postfix_parens[:postfix][:exit]).to eq('exit')
      expect(postfix_parens[:postfix][:postfix_argument][:integer]).to eq('0')
    end

    it 'recognizes if postfix' do
      expect(postfix_if[:if_postfix][:if]).to eq('if')
      expect(postfix_if[:if_postfix][:postfix_argument][:reference]).to eq('true')
    end

    it 'recognizes unless postfix' do
      expect(postfix_unless[:unless_postfix][:unless]).to eq('unless')
      expect(postfix_unless[:unless_postfix][:postfix_argument][:reference]).to eq('false')
    end

    it 'recognizes keyword followed by postfix' do
      expect(keyword_postfix_a[:return]).to eq('return')
      expect(keyword_postfix_a[:unless_postfix][:postfix_argument][:reference]).to eq('false')

      expect(keyword_postfix_b[:reference]).to eq('nil')
      expect(keyword_postfix_b[:if_postfix][:postfix_argument][:invocation][:reference]).to eq('empty')
      expect(keyword_postfix_b[:if_postfix][:postfix_argument][:invocation][:arguments]).to eq([])
    end

    it 'recognizes list expression' do
      expect(list[:list]).to eq([])
    end
  end

  describe 'atomic literals' do
    let(:integer) { parser.numeric.parse('42') }
    let(:decimal) { parser.numeric.parse('4.2') }
    let(:negative) { parser.numeric.parse('-3') }
    let(:long) { parser.numeric.parse('123_456_789') }
    let(:character_digit) { parser.character.parse('`9') }
    let(:character_alpha) { parser.character.parse('`f') }
    let(:symbol_string_digit) { parser.string.parse(':0') }
    let(:symbol_string_alpha) { parser.string.parse(':one') }
    let(:single_string) { parser.string.parse('\'two\'') }
    let(:double_string) { parser.string.parse('"three"') }

    let(:here_doc) do
      parser.string.parse(<<-RIP.split("\n").map(&:strip).join("\n"))
                          <<HERE_DOC
                          here docs are good for multi-line strings
                          HERE_DOC
                          RIP
    end

    let(:regex) { parser.regular_expression.parse('/hello/') }

    it 'recognizes numbers' do
      expect(integer[:integer]).to eq('42')
      expect(decimal[:decimal]).to eq('4.2')
      expect(negative[:integer]).to eq('3')
      expect(negative[:sign]).to eq('-')
      expect(long[:integer]).to eq('123_456_789')
    end

    it 'recognizes characters' do
      expect(character_digit[:character]).to eq('9')
      expect(character_alpha[:character]).to eq('f')
    end

    it 'recognizes strings' do
      expect(symbol_string_digit[:string]).to eq('0')
      expect(symbol_string_alpha[:string]).to eq('one')
      expect(single_string[:string]).to eq('two')
      expect(double_string[:string]).to eq('three')
      expect(here_doc[:string]).to eq("here docs are good for multi-line strings\n")
    end

    it 'recognizes regular expressions' do
      expect(regex[:regex]).to eq('hello')
    end
  end

  describe 'molecular literals' do
    let(:kvp) { parser.key_value_pair.parse('5: \'five\'') }
    let(:reference_kvp) { parser.key_value_pair.parse('Exception: e') }
    let(:range) { parser.range.parse('1..3') }
    let(:reference_range) { parser.range.parse('1...age') }

    let(:empty_hash) { parser.hash_literal.parse('{}') }
    let(:single_hash) { parser.hash_literal.parse('{:name: :Thomas}') }
    let(:multi_hash) do
      parser.hash_literal.parse(<<-RIP.strip)
                                {
                                  :age: 31,
                                  :name: :Thomas
                                }
                                RIP
    end

    let(:empty_list) { parser.list.parse('[]') }
    let(:single_list) { parser.list.parse('[:Thomas]') }
    let(:multi_list) do
      parser.list.parse(<<-RIP.strip)
                        [
                          31,
                          :Thomas
                        ]
                        RIP
    end

    it 'recognizes key-value pairs' do
      expect(kvp[:key][:integer]).to eq('5')
      expect(kvp[:value][:string]).to eq('five')

      expect(reference_kvp[:key][:reference]).to eq('Exception')
      expect(reference_kvp[:value][:reference]).to eq('e')
    end

    it 'recognizes ranges' do
      expect(range[:start][:integer]).to eq('1')
      expect(range[:end][:integer]).to eq('3')
      expect(range[:exclusivity]).to be_nil

      expect(reference_range[:start][:integer]).to eq('1')
      expect(reference_range[:end][:reference]).to eq('age')
      expect(reference_range[:exclusivity]).to eq('.')
    end

    it 'recognizes hashes' do
      expect(empty_hash[:hash]).to eq([])

      expect(single_hash[:hash].first[:key][:string]).to eq('name')
      expect(single_hash[:hash].first[:value][:string]).to eq('Thomas')

      expect(multi_hash[:hash].first[:key][:string]).to eq('age')
      expect(multi_hash[:hash].first[:value][:integer]).to eq('31')
      expect(multi_hash[:hash].last[:key][:string]).to eq('name')
      expect(multi_hash[:hash].last[:value][:string]).to eq('Thomas')
    end

    it 'recognizes lists' do
      expect(empty_list[:list]).to eq([])

      expect(single_list[:list].first[:string]).to eq('Thomas')

      expect(multi_list[:list].first[:integer]).to eq('31')
      expect(multi_list[:list].last[:string]).to eq('Thomas')
    end
  end

  describe '#invocation' do
    let(:invocation_literal) { parser.invocation.parse('-> () {}()') }
    let(:invocation_reference) { parser.invocation.parse('full_name()') }
    let(:invocation_reference_arguments) { parser.invocation.parse('full_name(:Thomas, :Ingram)') }
    let(:invocation_operator) { parser.invocation.parse('2 + 2') }

    it 'recognizes lambda literal invocation' do
      expect(invocation_literal[:invocation][:arguments]).to eq([])
    end

    it 'recognizes lambda reference invocation' do
      expect(invocation_reference[:invocation][:reference]).to eq('full_name')
      expect(invocation_reference[:invocation][:arguments]).to eq([])
    end

    it 'recognizes lambda reference invocation arguments' do
      expect(invocation_reference_arguments[:invocation][:reference]).to eq('full_name')
      expect(invocation_reference_arguments[:invocation][:arguments].first[:string]).to eq('Thomas')
      expect(invocation_reference_arguments[:invocation][:arguments].last[:string]).to eq('Ingram')
    end

    it 'recognizes operator invocation' do
      expect(invocation_operator[:invocation][:operand][:integer]).to eq('2')
      expect(invocation_operator[:invocation][:operator][:reference]).to eq('+')
      expect(invocation_operator[:invocation][:argument][:integer]).to eq('2')
    end
  end
end
