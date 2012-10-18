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
      expect(comment).to match_tree(:comment => ' this is a comment')
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
        expect(parser.reference.parse(reference)).to match_tree(:reference => reference)
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
      [
        'nilly',
        'nil',
        'true',
        'false',
        'Kernel'
      ].each do |reference|
        expect(parser.reference.parse(reference)).to match_tree(:reference => reference)
      end
    end

    it 'assigns to a reference' do
      expect(assignment).to match_tree(:assignment => {:reference => 'favorite_language', :value => {:string => 'rip'}})
    end
  end

  describe '#block_expression' do
    context 'parameters' do
      let(:block_empty) { parser.block_expression.parse('-> {}') }
      let(:block_empty_parens) { parser.block_expression.parse('class () {}') }

      let(:block_parameter) { parser.block_expression.parse('unless (:name) {}') }
      let(:block_parameter_default) { parser.block_expression.parse('-> (name = :rip) {}') }
      let(:block_multiple_parameters) { parser.block_expression.parse('case (one, two) {}') }
      let(:block_parameter_parameter_default) { parser.block_expression.parse('=> (platform, name = :rip) {}') }
      let(:block_block_parameter) { parser.block_expression.parse('class (class () {}) {}') }

      it 'recognizes empty blocks' do
        expect(block_empty).to match_tree(:block => {:lambda_dash => '->', :body => []})
        expect(block_empty_parens).to match_tree(:block => {:class => 'class', :body => []})
      end

      it 'recognizes blocks with parameter' do
        expect(block_parameter).to match_tree(:block => {:unless => 'unless', :parameters => [{:string => 'name'}]})
      end

      it 'recognizes blocks with default parameter' do
        expect(block_parameter_default).to match_tree(:block => {:parameters => [{:assignment => {:reference => 'name', :value => {:string => 'rip'}}}]})
      end

      it 'recognizes blocks with multiple parameters' do
        expect(block_multiple_parameters).to match_tree(:block => {:parameters => [{:reference => 'one'}, {:reference => 'two'}]})
      end

      it 'recognizes blocks with parameter and default parameter' do
        expect(block_parameter_parameter_default).to match_tree(:block => {:parameters => [{:reference => 'platform'}, {:assignment => {:reference => 'name'}}]})
      end

      it 'recognizes blocks with block parameters' do
        expect(block_block_parameter).to match_tree(:block => {:class => 'class', :parameters => [{:block => {:class => 'class'}}]})
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
        expect(block_comment).to match_tree(:comment => ' comment')
      end

      it 'recognizes references inside blocks' do
        expect(block_reference).to match_tree(:reference => 'name')
      end

      it 'recognizes assignments inside blocks' do
        expect(block_assignment).to match_tree(:assignment => {:reference => 'x', :value => {:string => 'y'}})
      end

      it 'recognizes invocations inside blocks' do
        expect(block_invocation).to match_tree(:invocation => {:reference => 'run!', :arguments => []})
      end

      it 'recognizes operator invocations inside blocks' do
        expect(block_invocation_operator).to match_tree(:invocation => {:operand => {:reference => 'steam'}, :operator => {:reference => 'will'}, :argument => {:string => 'rise'}})
      end

      it 'recognizes literals inside blocks' do
        expect(block_literal).to match_tree(:character => '3')
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
      expect(keyword).to match_tree(:return => 'return')
    end

    it 'recognizes postfix followed by postfix' do
      expect(postfix_postfix).to match_tree(:postfix => {:exit => 'exit', :postfix_argument => {:integer => '1'}}, :if_postfix => {:postfix_argument => {:string => 'error'}})
    end

    it 'recognizes postfix' do
      expect(postfix).to match_tree(:postfix => {:exit => 'exit', :postfix_argument => {:integer => '0'}})
    end

    it 'recognizes postfix with parenthesis around argument' do
      expect(postfix_parens).to match_tree(:postfix => {:exit => 'exit', :postfix_argument => {:integer => '0'}})
    end

    it 'recognizes if postfix' do
      expect(postfix_if).to match_tree(:if_postfix => {:if => 'if', :postfix_argument => {:reference => 'true'}})
    end

    it 'recognizes unless postfix' do
      expect(postfix_unless).to match_tree(:unless_postfix => {:unless => 'unless', :postfix_argument => {:reference => 'false'}})
    end

    it 'recognizes keyword followed by postfix' do
      expect(keyword_postfix_a).to match_tree(:return => 'return', :unless_postfix => {:postfix_argument => {:reference => 'false'}})

      expect(keyword_postfix_b).to match_tree(:reference => 'nil', :if_postfix => {:postfix_argument => {:invocation => {:reference => 'empty', :arguments => []}}})
    end

    it 'recognizes list expression' do
      expect(list).to match_tree(:list => [])
    end

    context 'nested parenthesis' do
      let(:parens) { parser.simple_expression.parse('(0)') }
      let(:gnarly_parens) { parser.simple_expression.parse('((((((l((1 + (((2 - 3)))))))))))') }

      # it 'recognizes anything surrounded by parenthesis', :focus do
      #   expect(parens).to match_tree(:phrase => { :integer => '0' })
      # end

      # it 'recognizes anything surrounded by parenthesis with crazy nesting', :focus do
      #   puts; puts '((((((l((1 + (((2 - 3)))))))))))'; puts :gnarly_parens, gnarly_parens.inspect
      #   expect(gnarly_parens[:invocation][:reference]).to eq('l')
      #   expect(gnarly_parens[:invocation][:parameters][0][:operator_invocation][:operand]).to eq('1')
      #   expect(gnarly_parens[:invocation][:parameters][0][:operator_invocation][:operator]).to eq('+')
      #   expect(gnarly_parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:operand]).to eq('2')
      #   expect(gnarly_parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:operator]).to eq('-')
      #   expect(gnarly_parens[:invocation][:parameters][0][:operator_invocation][:argument][:operator_invocation][:argument]).to eq('3')
      # end
    end

    describe 'property chaining' do
      let(:chain_property) { parser.simple_expression.parse('0.one.two.three') }
      let(:change_invocation) { parser.object.parse('zero().one().two().three()') }
      let(:chain_property_invocation) { parser.simple_expression.parse('0.one().two.three()') }
      let(:operator_chain) { parser.simple_expression.parse('(1 - 2).zero?()') }

      it 'recognizes property chains' do
        expect(chain_property).to match_tree(:integer => '0', :property_chain => [{:reference => 'one'}, {:reference => 'two'}, {:reference => 'three'}])
      end

      it 'recognizes property chains with invocations' do
        expected = {
          :invocation => {:reference => 'zero'},
          :property_chain => [
            {:invocation => {:reference => 'one'}},
            {:invocation => {:reference => 'two'}},
            {:invocation => {:reference => 'three'}}
          ]
        }
        expect(change_invocation).to match_tree(expected)
      end

      # it 'recognizes chaining with properies and invocations', :focus do
      #   puts; puts '0.one().two.three()'; puts "chain_property_invocation => #{chain_property_invocation.inspect}"
      #   expect(chain_property_invocation[:integer]).to eq('0')
      #   expect(chain_property_invocation[:invocation][:reference]).to eq('one')
      #   expect(chain_property_invocation[:invocation][:parameters]).to eq([])
      #   expect(chain_property_invocation[:invocation][:property][:reference]).to eq('two')
      #   expect(chain_property_invocation[:invocation][:property][:invocation][:reference]).to eq('three')
      #   expect(chain_property_invocation[:invocation][:property][:invocation][:parameters]).to eq([])
      #   expect(chain_property_invocation[:invocation][:property][:invocation][:property]).to be_nil
      # end

      # it 'recognizes chaining off opererators', :focus do
      #   puts; puts '(1 - 2).zero?()'; puts "operator_chain => #{operator_chain.inspect}"
      #   expect(operator_chain[:operator_invocation][:operand]).to eq('1')
      #   expect(operator_chain[:operator_invocation][:operator]).to eq('-')
      #   expect(operator_chain[:operator_invocation][:argument]).to eq('2')
      #   expect(operator_chain[:operator_invocation][:invocation][:reference]).to eq('zero')
      #   expect(operator_chain[:operator_invocation][:invocation][:parameters]).to eq([])
      #   expect(operator_chain[:operator_invocation][:invocation][:property]).to be_nil
      # end
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
      expect(integer).to match_tree(:integer => '42')
      expect(decimal).to match_tree(:decimal => '4.2')
      expect(negative).to match_tree(:sign => '-', :integer => '3')
      expect(long).to match_tree(:integer => '123_456_789')
    end

    it 'recognizes characters' do
      expect(character_digit).to match_tree(:character => '9')
      expect(character_alpha).to match_tree(:character => 'f')
    end

    it 'recognizes strings' do
      expect(symbol_string_digit).to match_tree(:string => '0')
      expect(symbol_string_alpha).to match_tree(:string => 'one')
      expect(single_string).to match_tree(:string => 'two')
      expect(double_string).to match_tree(:string => 'three')
      expect(here_doc).to match_tree(:string => "here docs are good for multi-line strings\n")
    end

    it 'recognizes regular expressions' do
      expect(regex).to match_tree(:regex => 'hello')
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
      expect(kvp).to match_tree(:key => {:integer => '5'}, :value => {:string => 'five'})

      expect(reference_kvp).to match_tree(:key => {:reference => 'Exception'}, :value => {:reference => 'e'})
    end

    it 'recognizes ranges' do
      expect(range).to match_tree(:start => {:integer => '1'}, :end => {:integer => '3'}, :exclusivity => nil)

      expect(reference_range).to match_tree(:start => {:integer => '1'}, :end => {:reference => 'age'}, :exclusivity => '.')
    end

    it 'recognizes hashes' do
      expect(empty_hash).to match_tree(:hash => [])

      expect(single_hash).to match_tree(:hash => [{:key => {:string => 'name'}, :value => {:string => 'Thomas'}}])

      expect(multi_hash).to match_tree(:hash => [{:key => {:string => 'age'}, :value => {:integer => '31'}}, {:key => {:string => 'name'}, :value => {:string => 'Thomas'}}])
    end

    it 'recognizes lists' do
      expect(empty_list).to match_tree(:list => [])

      expect(single_list).to match_tree(:list => [{:string => 'Thomas'}])

      expect(multi_list).to match_tree(:list => [{:integer => '31'}, {:string => 'Thomas'}])
    end
  end

  describe '#invocation' do
    let(:invocation_literal) { parser.invocation.parse('-> () {}()') }
    let(:invocation_reference) { parser.invocation.parse('full_name()') }
    let(:invocation_reference_arguments) { parser.invocation.parse('full_name(:Thomas, :Ingram)') }
    let(:invocation_operator) { parser.invocation.parse('2 + 2') }

    it 'recognizes lambda literal invocation' do
      expect(invocation_literal).to match_tree(:invocation => {:arguments => []})
    end

    it 'recognizes lambda reference invocation' do
      expect(invocation_reference).to match_tree(:invocation => {:reference => 'full_name', :arguments => []})
    end

    it 'recognizes lambda reference invocation arguments' do
      expect(invocation_reference_arguments).to match_tree(:invocation => {:reference => 'full_name', :arguments => [{:string => 'Thomas'}, {:string => 'Ingram'}]})
    end

    it 'recognizes operator invocation' do
      expect(invocation_operator).to match_tree(:invocation => {:operand => {:integer => '2'}, :operator => {:reference => '+'}, :argument => {:integer => '2'}})
    end
  end
end
