require 'spec_helper'

describe Rip::Compiler::AST do
  let(:location) { location_for }
  let(:the_module) { syntax_tree(rip) }
  let(:statements) { the_module.body.statements }

  context 'some basics' do
    describe 'tree for empty module' do
      let(:rip) { '' }
      let(:empty_body) { Rip::Nodes::BlockBody.new(location, []) }
      let(:rip_module) { Rip::Nodes::Module.new(location, empty_body) }

      specify do
        expect(statements.count).to eq(0)
        expect(the_module).to eq(rip_module)
      end
    end

    describe 'tree for comments' do
      let(:rip) { '# this is a comment' }
      let(:empty_body) { Rip::Nodes::BlockBody.new(location, []) }
      let(:rip_module) { Rip::Nodes::Module.new(location, empty_body) }

      specify do
        expect(statements.count).to eq(0)
        expect(the_module).to eq(rip_module)
      end
    end
  end

  context 'single token module' do
    let(:rip) { 'rip' }
    let(:reference_node) { Rip::Nodes::Reference.new(location, rip) }

    it 'finds a single node' do
      expect(statements.count).to eq(1)
    end

    it 'finds a single reference as the first node' do
      expect(statements.first).to eq(reference_node)
    end
  end

  context 'empty literals' do
    context 'character' do
      let(:rip) { '`1' }
      let(:node) { Rip::Nodes::Character.new(location, '1') }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'string, symbol' do
      let(:rip) { ':one' }
      let(:node) { Rip::Nodes::String.new(location, rip_string_nodes(location.add_character(12), 'one')) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'string, single' do
      let(:rip) { "''" }
      let(:node) { Rip::Nodes::String.new(location, []) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'string, double' do
      let(:rip) { '""' }
      let(:node) { Rip::Nodes::String.new(location, []) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'regular expression' do
      let(:rip) { '//' }
      let(:node) { Rip::Nodes::RegularExpression.new(location, []) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'map' do
      let(:rip) { '{}' }
      let(:node) { Rip::Nodes::Map.new(location, []) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'list' do
      let(:rip) { '[]' }
      let(:node) { Rip::Nodes::List.new(location, []) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'key-value pair' do
      let(:rip) { 'a:b' }
      let(:key_node) { Rip::Nodes::Reference.new(location, 'a') }
      let(:value_node) { Rip::Nodes::Reference.new(location.add_character(2), 'b') }
      let(:node) { Rip::Nodes::KeyValue.new(location.add_character, key_node, value_node) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end

    context 'range' do
      let(:rip) { '1..3' }
      let(:start_node) { Rip::Nodes::Integer.new(location, '1') }
      let(:end_node) { Rip::Nodes::Integer.new(location.add_character(3), '3') }
      let(:node) { Rip::Nodes::Range.new(location.add_character, start_node, end_node, false) }
      let(:actual) { statements.first }

      specify { expect(actual.location).to eq(node.location) }
    end
  end

  context 'key-value pair' do
    subject { statements.first }
    let(:rip) { ':key: :value' }
    let(:key_characters) do
      [
        Rip::Nodes::Character.new(location.add_character(1), 'k'),
        Rip::Nodes::Character.new(location.add_character(2), 'e'),
        Rip::Nodes::Character.new(location.add_character(3), 'y')
      ]
    end
    let(:key_node) { Rip::Nodes::String.new(location, key_characters) }
    let(:value_characters) do
      [
        Rip::Nodes::Character.new(location.add_character(7), 'v'),
        Rip::Nodes::Character.new(location.add_character(8), 'a'),
        Rip::Nodes::Character.new(location.add_character(9), 'l'),
        Rip::Nodes::Character.new(location.add_character(10), 'u'),
        Rip::Nodes::Character.new(location.add_character(11), 'e')
      ]
    end
    let(:value_node) { Rip::Nodes::String.new(location.add_character(6), value_characters) }
    let(:key_value_node) { Rip::Nodes::KeyValue.new(location.add_character(4), key_node, value_node) }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the key-value node' do
      expect(statements.first).to eq(key_value_node)
    end

    specify { expect(subject.key).to eq(key_node) }
    specify { expect(subject.value).to eq(value_node) }
  end

  context 'range' do
    subject { statements.first }
    let(:rip) { '`a..`z' }
    let(:a_node) { Rip::Nodes::Character.new(location, 'a') }
    let(:z_node) { Rip::Nodes::Character.new(location.add_character(4), 'z') }
    let(:range_node) { Rip::Nodes::Range.new(location.add_character(2), a_node, z_node) }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the range node' do
      expect(statements.first).to eq(range_node)
    end

    specify { expect(subject.start).to eq(a_node) }
    specify { expect(subject.end).to eq(z_node) }
    specify { expect(subject.exclusivity).to be(false) }
  end

  context 'list' do
    subject { statements.first }

    let(:rip) { '[a, z]' }

    let(:a_node) { Rip::Nodes::Reference.new(location.add_character, 'a') }
    let(:z_node) { Rip::Nodes::Reference.new(location.add_character(4), 'z') }
    let(:list_node) { Rip::Nodes::List.new(location, [ a_node, z_node ]) }

    let(:list) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the range node' do
      expect(list.items.first).to eq(a_node)
      expect(list.items.last).to eq(z_node)

      expect(list).to eq(list_node)
    end
  end

  context 'map' do
    subject { statements.first }

    let(:rip) { '{a: z}' }

    let(:a_node) { Rip::Nodes::Reference.new(location.add_character, 'a') }
    let(:z_node) { Rip::Nodes::Reference.new(location.add_character(4), 'z') }
    let(:key_value_node) { Rip::Nodes::KeyValue.new(location.add_character(2), a_node, z_node) }

    let(:map_node) { Rip::Nodes::Map.new(location, [ key_value_node ]) }

    let(:map) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the key-value node' do
      expect(map.pairs.first).to eq(key_value_node)

      expect(map).to eq(map_node)
    end
  end

  context 'property' do
    subject { statements.first }
    let(:rip) { 'one.two' }
    let(:object_node) { Rip::Nodes::Reference.new(location, 'one') }
    let(:property_node) { Rip::Nodes::Property.new(location.add_character(3), object_node, 'two') }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the property node' do
      expect(statements.first).to eq(property_node)
    end

    specify { expect(subject.object).to eq(object_node) }
    specify { expect(subject.name).to eq('two') }
  end

  context 'assignment' do
    let(:line_two) { new_location(Pathname.pwd, 10, 2, 1) }
    let(:rip) { "# find me\nlanguage = :rip" }
    let(:reference_node) { Rip::Nodes::Reference.new(line_two, 'language') }
    let(:characters) do
      [
        Rip::Nodes::Character.new(line_two.add_character(12), 'r'),
        Rip::Nodes::Character.new(line_two.add_character(13), 'i'),
        Rip::Nodes::Character.new(line_two.add_character(14), 'p')
      ]
    end
    let(:string_node) { Rip::Nodes::String.new(line_two.add_character(11), characters) }
    let(:assignment_node) { Rip::Nodes::Assignment.new(line_two.add_character(9), reference_node, string_node) }

    let(:assignment) { statements.first }

    it 'has one top-level nodes' do
      expect(statements.count).to eq(1)
    end

    it 'finds an assignment' do
      expect(assignment).to eq(assignment_node)
      expect(assignment.lhs).to eq(reference_node)
      expect(assignment.rhs).to eq(string_node)
    end
  end

  context 'blocks' do
    let(:rip) { '-> (other) {}' }

    let(:parameter_nodes) { [ Rip::Nodes::Parameter.new(location.add_character(4), 'other') ] }
    let(:body_node) { Rip::Nodes::BlockBody.new(location.add_character(11), []) }
    let(:overload_node) { Rip::Nodes::Overload.new(location, parameter_nodes, body_node) }
    let(:lambda_node) { Rip::Nodes::Lambda.new(location, [ overload_node ]) }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the lambda' do
      expect(statements.first).to eq(lambda_node)
    end
  end

  context 'numbers' do
    context 'decimal' do
      let(:rip) { '3.14' }
      let(:decimal_node) { Rip::Nodes::Decimal.new(location, rip) }

      specify { expect(statements.first).to eq(decimal_node) }
    end

    context 'integer' do
      let(:rip) { '42' }
      let(:integer_node) { Rip::Nodes::Integer.new(location, rip) }

      specify { expect(statements.first).to eq(integer_node) }
    end
  end

  context 'lambdas' do
    let(:rip) { '-> (question, answer<System.Integer>) {}' }

    let(:system_type_node) { Rip::Nodes::Reference.new(location.add_character(21), 'System') }
    let(:integer_type_node) { Rip::Nodes::Property.new(location.add_character(27), system_type_node, 'Integer') }
    let(:parameter_nodes) do
      [
        Rip::Nodes::Parameter.new(location.add_character(6), 'question'),
        Rip::Nodes::Parameter.new(location.add_character(14), 'answer', integer_type_node)
      ]
    end
    let(:body_node) { Rip::Nodes::BlockBody.new(location.add_character(38), []) }
    let(:overload_node) { Rip::Nodes::Overload.new(location, parameter_nodes, body_node) }

    let(:overload_nodes) { [ overload_node ] }
    let(:lambda_node) { Rip::Nodes::Lambda.new(location, overload_nodes) }

    let(:overloads) { statements.first.overloads }
    let(:parameters) { overloads.first.parameters }

    it 'finds the lambda' do
      expect(statements.first).to eq(lambda_node)
    end

    it 'has one overload' do
      expect(overloads.count).to eq(1)
    end

    specify do
      expect(parameters.first).to eq(parameter_nodes.first)
      expect(parameters.last).to eq(parameter_nodes.last)
    end

    context 'with two overloads' do
      let(:rip) do
        strip_heredoc(<<-RIP)
          => {
            -> (a) { }
            -> (a, b) { }
          }
        RIP
      end

      let(:lambda_location) { location }
      let(:lambda_node) { Rip::Nodes::Lambda.new(lambda_location, [ overload_one_node, overload_two_node ]) }


      let(:overload_one_location) { lambda_location.add_character(4).add_line(1).add_character(2) }
      let(:overload_one_node) { Rip::Nodes::Overload.new(overload_one_location, [ parameter_a_node_1 ], overload_one_body_node) }

      let(:parameter_a_1_location) { overload_one_location.add_character(4) }
      let(:parameter_a_node_1) { Rip::Nodes::Parameter.new(parameter_a_1_location, 'a') }

      let(:overload_one_body_location) { parameter_a_1_location.add_character(3) }
      let(:overload_one_body_node) { Rip::Nodes::BlockBody.new(overload_one_body_location, []) }


      let(:overload_two_location) { overload_one_body_location.add_character(3).add_line(1).add_character(2) }
      let(:overload_two_node) { Rip::Nodes::Overload.new(overload_two_location, [ parameter_a_node_2, parameter_b_node ], overload_two_body_node) }

      let(:parameter_a_2_location) { overload_two_location.add_character(4) }
      let(:parameter_a_node_2) { Rip::Nodes::Parameter.new(parameter_a_2_location, 'a') }

      let(:parameter_b_location) { parameter_a_2_location.add_character(3) }
      let(:parameter_b_node) { Rip::Nodes::Parameter.new(parameter_b_location, 'b') }

      let(:overload_two_body_location) { parameter_b_location.add_character(3) }
      let(:overload_two_body_node) { Rip::Nodes::BlockBody.new(overload_two_body_location, []) }


      it 'finds the lambda' do
        expect(statements.first).to eq(lambda_node)
      end

      it 'has two overloads' do
        expect(overloads.count).to eq(2)

        overloads.each do |overload|
          expect(overload).to be_a(Rip::Nodes::Overload)
        end
      end
    end
  end

  context 'property assignment' do
    let(:rip) { '@.== = -> (other) {}' }

    let(:prototype_node) { Rip::Nodes::Reference.new(location, '@') }
    let(:property_node) { Rip::Nodes::Property.new(location.add_character, prototype_node, '==') }

    let(:assignment_node) { Rip::Nodes::Assignment.new(location.add_character(5), property_node, lambda_node) }

    let(:parameter_node) { Rip::Nodes::Parameter.new(location.add_character(11), 'other') }
    let(:body_node) { Rip::Nodes::BlockBody.new(location.add_character(18), []) }
    let(:overload_node) { Rip::Nodes::Overload.new(location.add_character(7), [ parameter_node ], body_node) }
    let(:lambda_node) { Rip::Nodes::Lambda.new(location.add_character(7), [ overload_node ]) }

    let(:assignment) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the assignment' do
      expect(assignment).to eq(assignment_node)
    end

    it 'assigns to the == property' do
      expect(assignment.lhs).to eq(property_node)
    end

    it 'assigns a lambda' do
      expect(assignment.rhs).to eq(lambda_node)
    end
  end

  shared_examples_for 'invocation' do
    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the plus invocation' do
      expect(invocation_plus).to eq(invocation_node_plus)
      expect(invocation_plus.arguments).to eq([two_node])
      expect(invocation_plus.callable).to eq(property_node_plus)
      expect(invocation_plus.callable.object).to eq(one_node)
      expect(invocation_plus.callable.name).to eq('+')
    end

    it 'finds the times invocation' do
      expect(invocation_times).to eq(invocation_node_times)
      expect(invocation_times.arguments).to eq([three_node])
      expect(invocation_times.callable).to eq(property_node_times)
      expect(invocation_times.callable.object).to eq(invocation_plus)
      expect(invocation_times.callable.name).to eq('*')
    end
  end

  context 'standard invocation' do
    let(:rip) { '1.+(2).*(3)' }

    let(:one_node) { Rip::Nodes::Integer.new(location, '1') }
    let(:two_node) { Rip::Nodes::Integer.new(location.add_character(4), '2') }
    let(:three_node) { Rip::Nodes::Integer.new(location.add_character(9), '3') }

    let(:property_node_plus) { Rip::Nodes::Property.new(location.add_character, one_node, '+') }
    let(:invocation_node_plus) { Rip::Nodes::Invocation.new(location.add_character(3), property_node_plus, [two_node]) }

    let(:property_node_times) { Rip::Nodes::Property.new(location.add_character(6), invocation_node_plus, '*') }
    let(:invocation_node_times) { Rip::Nodes::Invocation.new(location.add_character(8), property_node_times, [three_node]) }

    let(:invocation_times) { statements.first }
    let(:invocation_plus) { invocation_times.callable.object }

    it_behaves_like 'invocation'
  end

  context 'operator invocation' do
    let(:rip) { '1 + 2 * 3' }

    let(:one_node) { Rip::Nodes::Integer.new(location, '1') }
    let(:two_node) { Rip::Nodes::Integer.new(location.add_character(4), '2') }
    let(:three_node) { Rip::Nodes::Integer.new(location.add_character(8), '3') }

    let(:property_node_plus) { Rip::Nodes::Property.new(location.add_character(2), one_node, '+') }
    let(:invocation_node_plus) { Rip::Nodes::Invocation.new(location.add_character(2), property_node_plus, [two_node]) }

    let(:property_node_times) { Rip::Nodes::Property.new(location.add_character(6), invocation_node_plus, '*') }
    let(:invocation_node_times) { Rip::Nodes::Invocation.new(location.add_character(6), property_node_times, [three_node]) }

    let(:invocation_times) { statements.first }
    let(:invocation_plus) { invocation_times.callable.object }

    it_behaves_like 'invocation'
  end

  context 'switch blocks' do
    let(:rip) do
      strip_heredoc(<<-RIP)
        switch (x) {
          case (1) {}
          case (2) {}
          case (3) {}
          else     {}
        }
      RIP
    end

    let(:line_2) { location.add_character(12).add_line }
    let(:case_1_argument_node) { Rip::Nodes::Integer.new(line_2.add_character(8), '1') }
    let(:case_1_body_node) { Rip::Nodes::BlockBody.new(line_2.add_character(11), []) }
    let(:case_1_node) { Rip::Nodes::Case.new(line_2.add_character(2), [ case_1_argument_node ], case_1_body_node) }

    let(:line_3) { line_2.add_character(13).add_line }
    let(:case_2_argument_node) { Rip::Nodes::Integer.new(line_3.add_character(8), '2') }
    let(:case_2_body_node) { Rip::Nodes::BlockBody.new(line_3.add_character(11), []) }
    let(:case_2_node) { Rip::Nodes::Case.new(line_3.add_character(2), [ case_2_argument_node ], case_2_body_node) }

    let(:line_4) { line_3.add_character(13).add_line }
    let(:case_3_argument_node) { Rip::Nodes::Integer.new(line_4.add_character(8), '3') }
    let(:case_3_body_node) { Rip::Nodes::BlockBody.new(line_4.add_character(11), []) }
    let(:case_3_node) { Rip::Nodes::Case.new(line_4.add_character(2), [ case_3_argument_node ], case_3_body_node) }

    let(:line_5) { line_4.add_character(13).add_line }
    let(:else_body_node) { Rip::Nodes::BlockBody.new(line_5.add_character(11), []) }
    let(:else_node) { Rip::Nodes::Else.new(line_5.add_character(2), else_body_node) }

    let(:switch_argument_node) { Rip::Nodes::Reference.new(location.add_character(8), 'x') }
    let(:switch_node) { Rip::Nodes::Switch.new(location, switch_argument_node, [ case_1_node, case_2_node, case_3_node ], else_node) }

    let(:switch_block) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'finds the switch' do
      expect(switch_block.case_blocks[0]).to eq(switch_node.case_blocks[0])
      expect(switch_block.case_blocks[1]).to eq(switch_node.case_blocks[1])
      expect(switch_block.case_blocks[2]).to eq(switch_node.case_blocks[2])

      expect(switch_block.else_block).to eq(switch_node.else_block)

      expect(switch_block).to eq(switch_node)
    end

    context 'without else' do
      let(:rip) { 'switch { case (true) { 42 } }' }

      it 'is invalid' do
        expect { statements }.to raise_error(Rip::Exceptions::SyntaxError)
      end
    end
  end

  context 'interpolation for regular expression' do
    let(:rip) { '/#{a}b/' }

    let(:reference) { Rip::Nodes::Reference.new(location.add_character(3), 'a') }

    let(:virtual_receiver) { Rip::Nodes::BlockBody.new(location.add_character(1), [ reference ]) }
    let(:virtual_to_string) { Rip::Nodes::Property.new(location.add_character(1), virtual_receiver, 'to_string') }
    let(:virtual_invocation_string) { Rip::Nodes::Invocation.new(location.add_character(1), virtual_to_string, []) }

    let(:virtual_to_regular_expression) { Rip::Nodes::Property.new(location.add_character(1), virtual_invocation_string, 'to_regular_expression') }
    let(:virtual_invocation) { Rip::Nodes::Invocation.new(location.add_character(1), virtual_to_regular_expression, []) }

    let(:plus) { Rip::Nodes::Property.new(location.add_character(4), virtual_invocation, '+') }

    let(:character) { Rip::Nodes::Character.new(location.add_character(5), 'b') }
    let(:regular_expression) { Rip::Nodes::RegularExpression.new(location, [ character ]) }

    let(:concatenation_node) { Rip::Nodes::Invocation.new(location.add_character(4), plus, [ regular_expression ]) }

    let(:concatenation) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'transforms interpolation into regular expression concatenation' do
      expect(concatenation.callable.object).to eq(virtual_invocation)
      expect(concatenation.callable).to eq(plus)
      expect(concatenation.arguments.first).to eq(regular_expression)

      expect(concatenation).to eq(concatenation_node)
    end
  end

  context 'interpolation for string' do
    let(:rip) { '"#{a}b"' }

    let(:reference) { Rip::Nodes::Reference.new(location.add_character(3), 'a') }

    let(:virtual_receiver) { Rip::Nodes::BlockBody.new(location.add_character(1), [ reference ]) }
    let(:virtual_to_string) { Rip::Nodes::Property.new(location.add_character(1), virtual_receiver, 'to_string') }
    let(:virtual_invocation) { Rip::Nodes::Invocation.new(location.add_character(1), virtual_to_string, []) }

    let(:plus) { Rip::Nodes::Property.new(location.add_character(4), virtual_invocation, '+') }

    let(:character) { Rip::Nodes::Character.new(location.add_character(5), 'b') }
    let(:string) { Rip::Nodes::String.new(location, [ character ]) }

    let(:concatenation_node) { Rip::Nodes::Invocation.new(location.add_character(4), plus, [ string ]) }

    let(:concatenation) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'transforms interpolation into string concatenation' do
      expect(concatenation.callable.object).to eq(virtual_invocation)
      expect(concatenation.callable).to eq(plus)
      expect(concatenation.arguments.first).to eq(string)

      expect(concatenation).to eq(concatenation_node)
    end
  end

  context 'binary conditional block' do
    let(:rip) do
      strip_heredoc(<<-RIP)
        if (true) { :hello }
        else      { :goodbye }
      RIP
    end

    let(:reference_node) { Rip::Nodes::Reference.new(location.add_character(4), 'true') }

    let(:hello_node) { Rip::Nodes::String.new(location.add_character(12), rip_string_nodes(location.add_character(12), 'hello')) }
    let(:true_body) { Rip::Nodes::BlockBody.new(location.add_character(10), [ hello_node ]) }

    let(:line_2) { location.add_character(20).add_line }
    let(:goodbye_node) { Rip::Nodes::String.new(line_2.add_character(12), rip_string_nodes(line_2.add_character(12), 'goodbye')) }
    let(:false_body) { Rip::Nodes::BlockBody.new(line_2.add_character(10), [ goodbye_node ]) }

    let(:if_else_node) { Rip::Nodes::If.new(location, reference_node, true_body, false_body) }

    let(:if_else) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'transforms into if' do
      expect(if_else.argument).to eq(reference_node)

      expect(if_else.true_body).to eq(true_body)
      expect(if_else.false_body).to eq(false_body)

      expect(if_else).to eq(if_else_node)
    end
  end

  context 'exception handling' do
    let(:rip) do
      strip_heredoc(<<-RIP)
        try {
          # danger!
        }
        catch (AppError: e) {
          # rescue specific
        }
        catch (Exception: e) {
          # rescue generic
        }
        finally {
          # always run
        }
      RIP
    end

    let(:line_2) { location.add_character(5).add_line }
    let(:danger_body_node) { Rip::Nodes::BlockBody.new(location.add_character(4), []) }

    let(:line_3) { line_2.add_character(11).add_line }

    let(:line_4) { line_3.add_character(1).add_line }

    let(:line_5) { line_4.add_character(21).add_line }
    let(:specific_argument_key) { Rip::Nodes::Reference.new(line_4.add_character(7), 'AppError') }
    let(:specific_argument_value) { Rip::Nodes::Reference.new(line_4.add_character(17), 'e') }
    let(:specific_argument) { Rip::Nodes::KeyValue.new(line_4.add_character(15), specific_argument_key, specific_argument_value) }
    let(:specific_body_node) { Rip::Nodes::BlockBody.new(line_4.add_character(20), []) }
    let(:specific_block_node) { Rip::Nodes::Catch.new(line_4, specific_argument, specific_body_node) }

    let(:line_6) { line_5.add_character(19).add_line }

    let(:line_7) { line_6.add_character(1).add_line }

    let(:line_8) { line_7.add_character(22).add_line }
    let(:generic_argument_key) { Rip::Nodes::Reference.new(line_7.add_character(7), 'Exception') }
    let(:generic_argument_value) { Rip::Nodes::Reference.new(line_7.add_character(18), 'e') }
    let(:generic_argument) { Rip::Nodes::KeyValue.new(line_7.add_character(16), generic_argument_key, generic_argument_value) }
    let(:generic_body_node) { Rip::Nodes::BlockBody.new(line_7.add_character(21), []) }
    let(:generic_block_node) { Rip::Nodes::Catch.new(line_7, generic_argument, generic_body_node) }

    let(:line_9) { line_8.add_character(18).add_line }

    let(:line_10) { line_9.add_character(1).add_line }

    let(:line_11) { line_10.add_character(9).add_line }
    let(:always_body_node) { Rip::Nodes::BlockBody.new(line_10.add_character(8), []) }
    let(:always_block_node) { Rip::Nodes::Finally.new(line_10, always_body_node) }

    let(:try_etc_node) { Rip::Nodes::Try.new(location, danger_body_node, [ specific_block_node, generic_block_node ], always_block_node) }

    let(:try_etc) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'transforms into try with two catches and finally' do
      expect(try_etc.attempt_body).to eq(danger_body_node)

      expect(try_etc.catch_blocks.first).to eq(specific_block_node)
      expect(try_etc.catch_blocks.last).to eq(generic_block_node)

      expect(try_etc.finally_block).to eq(always_block_node)

      expect(try_etc).to eq(try_etc_node)
    end
  end

  context 'returning keyword with explicit payload' do
    let(:rip) { 'throw e' }

    let(:payload_node) { Rip::Nodes::Reference.new(location.add_character(6), 'e') }
    let(:keyword_node) { Rip::Nodes::Throw.new(location, payload_node) }

    let(:keyword) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'wraps payload with the keyword' do
      expect(keyword.payload).to eq(payload_node)
      expect(keyword).to eq(keyword_node)
    end
  end

  context 'returning keyword with implicit payload' do
    let(:rip) { 'return' }

    let(:payload_node) { Rip::Nodes::BlockBody.new(location, []) }
    let(:keyword_node) { Rip::Nodes::Throw.new(location, payload_node) }

    let(:keyword) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'wraps payload with the keyword' do
      expect(keyword.payload).to eq(payload_node)
      expect(keyword).to eq(keyword_node)
    end
  end

  context 'type with ignored parents' do
    let(:rip) { 'type {}' }

    let(:type_body_node) { Rip::Nodes::BlockBody.new(location.add_character(5), []) }
    let(:type_node) { Rip::Nodes::Type.new(location, [], type_body_node) }

    let(:type) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'is a type (with no parents)' do
      expect(type.super_types).to eq([])
      expect(type.body).to eq(type_body_node)
      expect(type).to eq(type_node)
    end
  end

  context 'type with unspecified parents' do
    let(:rip) { 'type () {}' }

    let(:type_body_node) { Rip::Nodes::BlockBody.new(location.add_character(8), []) }
    let(:type_node) { Rip::Nodes::Type.new(location, [], type_body_node) }

    let(:type) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'is a type (with no parents)' do
      expect(type.super_types).to eq([])
      expect(type.body).to eq(type_body_node)
      expect(type).to eq(type_node)
    end
  end

  context 'type with explicit parents' do
    let(:rip) { 'type (parent_1, parent_2) {}' }

    let(:parent_1) { Rip::Nodes::Reference.new(location.add_character(6), 'parent_1') }
    let(:parent_2) { Rip::Nodes::Reference.new(location.add_character(16), 'parent_2') }

    let(:type_body_node) { Rip::Nodes::BlockBody.new(location.add_character(26), []) }
    let(:type_node) { Rip::Nodes::Type.new(location, [ parent_1, parent_2 ], type_body_node) }

    let(:type) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'is a type (with two parents)' do
      expect(type.super_types.count).to eq(2)
      expect(type.super_types.first).to eq(parent_1)
      expect(type.super_types.last).to eq(parent_2)

      expect(type.body).to eq(type_body_node)

      expect(type).to eq(type_node)
    end
  end

  context 'list comments' do
    let(:rip) do
      strip_heredoc(<<-RIP)
        [
          1, # one
          2  # two
        ]
      RIP
    end

    let(:line_2) { location.add_character.add_line }
    let(:integer_1_node) { Rip::Nodes::Integer.new(line_2.add_character(2), '1') }

    let(:line_3) { line_2.add_character(10).add_line }
    let(:integer_2_node) { Rip::Nodes::Integer.new(line_3.add_character(2), '2') }

    let(:list_node) { Rip::Nodes::List.new(line_1, [ integer_1_node, integer_2_node ]) }

    let(:list) { statements.first }

    it 'has one top-level node' do
      expect(statements.count).to eq(1)
    end

    it 'is a list (with two integers)' do
      expect(list.items.count).to eq(2)
      expect(list.items.first).to eq(integer_1_node)
      expect(list.items.last).to eq(integer_2_node)
    end
  end
end
