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
      expect(parser.reference.parse('nil')[:reference][:nil]).to eq('nil')
      expect(parser.reference.parse('true')[:reference][:true]).to eq('true')
      expect(parser.reference.parse('false')[:reference][:false]).to eq('false')
      expect(parser.reference.parse('Kernel')[:reference][:kernel]).to eq('Kernel')
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

  describe '#block' do
    let(:empty_block) { parser.block.parse('{}') }
    # let(:empty_block) { parser.block.parse('-> {}') }
    let(:generic_block) do
      rip_block = <<-RIP_LIST
{
  # comment
  :words
}
      RIP_LIST
      parser.block.parse(rip_block.strip)
    end

    # let(:block_empty_parameters) { parser.block.parse('=> () {}')[:block] }
    # let(:block_block_parameter) { parser.block.parse('class (class () {}) {}')[:block] }
    # let(:block_parameter) { parser.block.parse('unless (name) {}')[:block] }
    # let(:block_super_parameter) { parser.block.parse(rip_block.strip)[:block] }
    # let(:block_paramter_default) { parser.block.parse('-> (name = :rip) {}')[:block] }
    # let(:block_multiple_parameters) { parser.block.parse(rip_block.strip)[:block] }
    # let(:block_parameter_parameter_default) { parser.block.parse('=> (platform, name = :rip) {}')[:block] }
    let(:class_block) { parser.class_literal.parse('class {}') }
    let(:class_block_empty) { parser.class_literal.parse('class () {}') }
    let(:class_block_parent) { parser.class_literal.parse('class (class () {}) {}') }
    let(:lambda_block) { parser.lambda_literal.parse('-> {}') }
    let(:lambda_block_empty) { parser.lambda_literal.parse('-> () {}') }
    let(:lambda_block_parameter) { parser.lambda_literal.parse('-> (name) {}') }
    let(:lambda_block_parameter_default) { parser.lambda_literal.parse('-> (name = :rip) {}') }
    let(:lambda_block_parameter_parameter_default) { parser.lambda_literal.parse('-> (platform, name = :rip) {}') }

    it 'recognizes empty blocks' do
      expect(empty_block[:body]).to eq([])
    end

    it 'recognizes useful blocks' do
      expect(generic_block[:body].count).to be(2)
      expect(generic_block[:body].first[:comment]).to eq(' comment')
      expect(generic_block[:body].last[:string]).to eq('words')
    end

    # it 'recognizes blocks with empty parameters', :failing do
    #   puts; puts "block_empty_parameters => #{block_empty_parameters.inspect}"
    #   expect(block_empty_parameters[:lambda_fat]).to eq('=>')
    #   expect(block_empty_parameters[:parameters]).to eq([])
    #   expect(block_empty_parameters[:body]).to eq([])
    # end

    # it 'recognizes blocks with block parameters', :failing do
    #   puts; puts "block_block_parameter => #{block_block_parameter.inspect}"
    #   expect(block_block_parameter[:class]).to eq('class')
    #   expect(block_block_parameter[:parameters].count).to eq(1)
    #   expect(block_block_parameter[:parameters].first[:block][:class]).to eq('class')
    # end

    # it 'recognizes blocks with parameters', :failing do
    #   puts; puts "block_parameter => #{block_parameter.inspect}"
    #   expect(block_parameter[:parameters].count).to eq(1)
    #   expect(block_parameter[:parameters].first[:unless]).to eq('unless')

    #   rip_block = <<-RIP_LIST
# class (super) {
# }
    #   RIP_LIST
    #   puts; puts "block_super_parameter => #{block_super_parameter.inspect}"
    #   expect(block_super_parameter[:parameters].count).to eq(1)
    #   expect(block_super_parameter[:parameters].first[:reference]).to eq('super')
    # end

    # it 'recognizes blocks with default parameter', :failing do
    #   puts; puts "block_paramter_default => #{block_paramter_default.inspect}"
    #   expect(block_paramter_default[:parameters].count).to eq(1)
    #   expect(block_paramter_default[:parameters].first[:assignment][:reference]).to eq('name')
    #   expect(block_paramter_default[:parameters].first[:assignment][:value][:string]).to eq('rip')
    # end

    # it 'recognizes blocks with multiple parameters', :failing do
    #   rip_block = <<-RIP_LIST
# class (one, two) {
# }
    #   RIP_LIST
    #   puts; puts "block_multiple_parameters => #{block_multiple_parameters.inspect}"
    #   expect(block_multiple_parameters[:parameters].count).to eq(2)
    #   expect(block_multiple_parameters[:parameters].first[:reference]).to eq('one')
    #   expect(block_multiple_parameters[:parameters].last[:reference]).to eq('two')
    # end

    # it 'recognizes blocks with parameter and default parameter', :failing do
    #   puts; puts block_parameter_parameter_default => #{block_parameter_parameter_default.inspect}"
    #   expect(block_parameter_parameter_default[:parameters].count).to eq(2)
    #   expect(block_parameter_parameter_default[:parameters].first[:reference]).to eq('platform')
    #   expect(block_parameter_parameter_default[:parameters].last[:assignment][:reference]).to eq('name')
    # end

    it 'recognizes classes' do
      expect(class_block[:class][:ancestors]).to be_nil
      expect(class_block[:class][:body]).to eq([])

      expect(class_block_empty[:class][:ancestors]).to eq([])
      expect(class_block_empty[:class][:body]).to eq([])
    end

    it 'recognizes classes with parent' do
      expect(class_block_parent[:class][:ancestors].count).to eq(1)
    end

    it 'recognizes lambdas' do
      expect(lambda_block[:lambda][:parameters]).to be_nil
      expect(lambda_block[:lambda][:body]).to eq([])

      expect(lambda_block_empty[:lambda][:parameters]).to eq([])
      expect(lambda_block_empty[:lambda][:body]).to eq([])
    end

    it 'recognizes lambdas with parameter' do
      expect(lambda_block_parameter[:lambda][:parameters].count).to eq(1)
      expect(lambda_block_parameter[:lambda][:parameters].first[:reference]).to eq('name')
    end

    it 'recognizes lambdas with default parameter' do
      expect(lambda_block_parameter_default[:lambda][:parameters].count).to eq(1)
      expect(lambda_block_parameter_default[:lambda][:parameters].first[:assignment][:reference]).to eq('name')
      expect(lambda_block_parameter_default[:lambda][:parameters].first[:assignment][:value][:string]).to eq('rip')
    end

    it 'recognizes lambdas with parameter and default parameter' do
      expect(lambda_block_parameter_parameter_default[:lambda][:parameters].count).to eq(2)
      expect(lambda_block_parameter_parameter_default[:lambda][:parameters].first[:reference]).to eq('platform')
      expect(lambda_block_parameter_parameter_default[:lambda][:parameters].last[:assignment][:reference]).to eq('name')
    end
  end

  describe 'simple expressions' do
    let(:keyword) { parser.simple_expression.parse('return;') }
    let(:postfix_postfix) { parser.simple_expression.parse('exit 1 if (:error)') }
    let(:postfix) { parser.simple_expression.parse('exit 0') }
    let(:keyword_postfix_a) { parser.simple_expression.parse('return unless (false);') }
    let(:keyword_postfix_b) { parser.simple_expression.parse('nil if (empty());') }
    let(:list) { parser.simple_expression.parse('[]') }

    it 'recognizes keyword' do
      expect(keyword[:return_keyword]).to eq('return')
    end

    it 'recognizes postfix followed by postfix' do
      expect(postfix_postfix[:exit_keyword]).to eq('exit')
      expect(postfix_postfix[:integer]).to eq('1')
      expect(postfix_postfix[:if_postfix][:binary_condition][:string]).to eq('error')
    end

    it 'recognizes postfix' do
      expect(postfix[:exit_keyword]).to eq('exit')
      expect(postfix[:integer]).to eq('0')
    end

    it 'recognizes keyword followed by postfix' do
      expect(keyword_postfix_a[:return_keyword]).to eq('return')
      expect(keyword_postfix_a[:unless_postfix][:binary_condition][:reference][:false]).to eq('false')

      expect(keyword_postfix_b[:reference][:nil]).to eq('nil')
      expect(keyword_postfix_b[:if_postfix][:binary_condition][:invocation][:reference]).to eq('empty')
      expect(keyword_postfix_b[:if_postfix][:binary_condition][:invocation][:arguments]).to eq([])
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
    let(:character) { parser.character.parse('`f') }
    let(:symbol_string) { parser.string.parse(':one') }
    let(:single_string) { parser.string.parse('\'two\'') }
    let(:double_string) { parser.string.parse('"three"') }

    let(:here_doc) do
      rip_doc = <<-RIP_DOC
<<HERE_DOC
here docs are good for multi-line strings
HERE_DOC
      RIP_DOC
      parser.string.parse(rip_doc)
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
      expect(character[:character]).to eq('f')
    end

    it 'recognizes strings' do
      expect(symbol_string[:string]).to eq('one')
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
      rip_hash = <<-RIP_HASH
{
  :age: 31,
  :name: :Thomas
}
      RIP_HASH
      parser.hash_literal.parse(rip_hash.strip)
    end

    let(:empty_list) { parser.list.parse('[]') }
    let(:single_list) { parser.list.parse('[:Thomas]') }
    let(:multi_list) do
      rip_list = <<-RIP_LIST
[
  31,
  :Thomas
]
      RIP_LIST
      parser.list.parse(rip_list.strip)
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

  describe 'flow controls' do
    let(:if_prefix) { parser.if_prefix.parse('if (true) {}') }
    let(:if_else_prefix) { parser.if_prefix.parse('if (true) {} else {}') }
    let(:unless_prefix) { parser.unless_prefix.parse('unless (true) {}') }
    let(:unless_else_prefix) { parser.unless_prefix.parse('unless (true) {} else {}') }
    let(:switch) { parser.switch.parse('switch { case (:rip) {} }') }

    let(:switch_full) do
      rip_switch = <<-RIP_SWITCH
switch (favorite_language) {
  case (:rip) {
  }
  else {
  }
}
      RIP_SWITCH
      parser.switch.parse(rip_switch.strip)
    end

    let(:tcf) do
      rip = <<-RIP
try {
}
catch (Exception: e) {
}
finally {
}
      RIP
      parser.exception_handling.parse(rip.strip)
    end

    it 'recognizes if prefixes' do
      expect(if_prefix[:if_prefix][:binary_condition][:reference][:true]).to eq('true')
      expect(if_prefix[:if_prefix][:body]).to eq([])

      expect(if_else_prefix[:if_prefix][:body]).to eq([])
      expect(if_else_prefix[:if_prefix][:else][:body]).to eq([])
    end

    it 'recognizes unless prefixes' do
      expect(unless_prefix[:unless_prefix][:binary_condition][:reference][:true]).to eq('true')
      expect(unless_prefix[:unless_prefix][:body]).to eq([])

      expect(unless_else_prefix[:unless_prefix][:body]).to eq([])
      expect(unless_else_prefix[:unless_prefix][:else][:body]).to eq([])
    end

    it 'recognizes switches' do
      expect(switch[:switch][:switch_test]).to be_nil
      expect(switch[:switch][:body].count).to eq(1)
      expect(switch[:switch][:body].first[:case][:case_qualifiers].first[:string]).to eq('rip')
      expect(switch[:switch][:body].first[:case][:body]).to eq([])
    end

    it 'recognizes full switches' do
      expect(switch_full[:switch][:switch_test][:reference]).to eq('favorite_language')
      expect(switch_full[:switch][:body].count).to eq(2)
      expect(switch_full[:switch][:body].first[:case][:case_qualifiers].first[:string]).to eq('rip')
      expect(switch_full[:switch][:body].first[:case][:body]).to eq([])
      expect(switch_full[:switch][:body].last[:else][:body]).to eq([])
    end

    it 'recognizes exception handling' do
      expect(tcf[:exception_handling][0][:try][:body]).to eq([])
      expect(tcf[:exception_handling][1][:catch][:key][:reference]).to eq('Exception')
      expect(tcf[:exception_handling][1][:catch][:value][:reference]).to eq('e')
      expect(tcf[:exception_handling][1][:catch][:body]).to eq([])
      expect(tcf[:exception_handling][2][:finally][:body]).to eq([])
    end
  end

  describe 'conditionals' do
    let(:if_condition) { parser.if_condition.parse('if (true)') }
    let(:unless_condition) { parser.unless_condition.parse('unless (false)') }
    let(:condition_a) { parser.binary_condition.parse('(:rip)') }
    let(:condition_b) { parser.binary_condition.parse('(l())') }

    it 'recognizes if conditions' do
      expect(if_condition[:binary_condition][:reference][:true]).to eq('true')
    end

    it 'recognizes unless conditions' do
      expect(unless_condition[:binary_condition][:reference][:false]).to eq('false')
    end

    it 'recognizes binary conditions' do
      expect(condition_a[:binary_condition][:string]).to eq('rip')

      expect(condition_b[:binary_condition][:invocation][:reference]).to eq('l')
      expect(condition_b[:binary_condition][:invocation][:arguments]).to eq([])
    end
  end
end
