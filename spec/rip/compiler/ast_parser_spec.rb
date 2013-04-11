require 'spec_helper'

describe Rip::Compiler::AST do
  let(:location) { location_for }
  let(:expressions) { syntax_tree(rip).expressions }

  context 'some basics' do
    describe 'tree for empty module' do
      let(:rip) { '' }
      let(:rip_module) { Rip::Nodes::Module.new(location, []) }

      specify do
        expect(syntax_tree(rip)).to eq(rip_module)
        expect(expressions.count).to eq(0)
      end
    end

    describe 'tree for comments' do
      let(:rip) { '# this is a comment' }
      let(:comment) { Rip::Nodes::Comment.new(location.add_character, ' this is a comment') }
      let(:rip_module) { Rip::Nodes::Module.new(location, [ comment ]) }

      specify do
        expect(expressions.count).to eq(1)
        expect(expressions.first).to eq(comment)
      end
    end
  end

  context 'single token module' do
    let(:rip) { 'rip' }
    let(:reference_node) { Rip::Nodes::Reference.new(location, rip) }

    it 'finds a single node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds a single reference as the first node' do
      expect(expressions.first).to eq(reference_node)
    end
  end

  context 'key-value pair' do
    subject { expressions.first }
    let(:rip) { ':key: :value' }
    let(:key_characters) do
      [
        Rip::Nodes::Character.new(location.add_character(1), 'k'),
        Rip::Nodes::Character.new(location.add_character(2), 'e'),
        Rip::Nodes::Character.new(location.add_character(3), 'y')
      ]
    end
    let(:key_node) { Rip::Nodes::String.new(location.add_character, key_characters) }
    let(:value_characters) do
      [
        Rip::Nodes::Character.new(location.add_character(7), 'v'),
        Rip::Nodes::Character.new(location.add_character(8), 'a'),
        Rip::Nodes::Character.new(location.add_character(9), 'l'),
        Rip::Nodes::Character.new(location.add_character(10), 'u'),
        Rip::Nodes::Character.new(location.add_character(11), 'e')
      ]
    end
    let(:value_node) { Rip::Nodes::String.new(location.add_character(7), value_characters) }
    let(:key_value_node) { Rip::Nodes::KeyValue.new(location.add_character, key_node, value_node) }

    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds the key-value node' do
      expect(expressions.first).to eq(key_value_node)
    end

    its(:key) { should eq(key_node) }
    its(:value) { should eq(value_node) }
  end

  context 'range' do
    subject { expressions.first }
    let(:rip) { '`a..`z' }
    let(:a_node) { Rip::Nodes::Character.new(location.add_character, 'a') }
    let(:z_node) { Rip::Nodes::Character.new(location.add_character(5), 'z') }
    let(:range_node) { Rip::Nodes::Range.new(location.add_character, a_node, z_node) }

    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds the range node' do
      expect(expressions.first).to eq(range_node)
    end

    its(:start) { should eq(a_node) }
    its(:end) { should eq(z_node) }
    its(:exclusivity) { should be_false }
  end

  context 'property' do
    subject { expressions.first }
    let(:rip) { 'one.two' }
    let(:object_node) { Rip::Nodes::Reference.new(location, 'one') }
    let(:property_node) { Rip::Nodes::Property.new(location.add_character(4), object_node, 'two') }

    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds the property node' do
      expect(expressions.first).to eq(property_node)
    end

    its(:object) { should eq(object_node) }
    its(:name) { should eq('two') }
  end

  context 'assignment' do
    let(:line_two) { new_location(:rspec, 10, 2, 1) }
    let(:rip) { "# find me\nlanguage = :rip" }
    let(:comment_node) { Rip::Nodes::Comment.new(location.add_character, ' find me') }
    let(:reference_node) { Rip::Nodes::Reference.new(line_two, 'language') }
    let(:characters) do
      [
        Rip::Nodes::Character.new(line_two.add_character(12), 'r'),
        Rip::Nodes::Character.new(line_two.add_character(13), 'i'),
        Rip::Nodes::Character.new(line_two.add_character(14), 'p')
      ]
    end
    let(:string_node) { Rip::Nodes::String.new(line_two.add_character(12), characters) }
    let(:assignment_node) { Rip::Nodes::Assignment.new(line_two.add_character(9), reference_node, string_node) }

    let(:comment) { expressions.first }
    let(:assignment) { expressions.last }

    it 'has two top-level nodes' do
      expect(expressions.count).to eq(2)
    end

    it 'knows the first node is a comment' do
      expect(comment).to eq(comment_node)
    end

    it 'finds an assignment as the last node' do
      expect(assignment).to eq(assignment_node)
      expect(assignment.reference).to eq(reference_node)
      expect(assignment.value).to eq(string_node)
    end
  end

  context 'blocks' do
    let(:rip) { '-> (other) {}' }

    let(:dash_rocket_node) { Rip::Utilities::Keywords[:dash_rocket] }
    let(:parameter_nodes) { [ Rip::Nodes::Reference.new(location.add_character(4), 'other') ] }
    let(:body_node) { Rip::Nodes::BlockBody.new(location.add_character(11), []) }
    let(:lambda_node) { Rip::Nodes::Lambda.new(location, dash_rocket_node, parameter_nodes, body_node) }

    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds the lambda' do
      expect(expressions.first).to eq(lambda_node)
    end
  end

  context 'property assignment' do
    let(:rip) { '@.== = -> (other) {}' }

    let(:prototype_node) { Rip::Nodes::Reference.new(location, '@') }
    let(:property_node) { Rip::Nodes::Property.new(location.add_character(2), prototype_node, '==') }

    let(:assignment_node) { Rip::Nodes::Assignment.new(location.add_character(5), property_node, lambda_node) }

    let(:dash_rocket_node) { Rip::Utilities::Keywords[:dash_rocket] }
    let(:parameter_node) { Rip::Nodes::Reference.new(location.add_character(11), 'other') }
    let(:body_node) { Rip::Nodes::BlockBody.new(location.add_character(18), []) }
    let(:lambda_node) { Rip::Nodes::Lambda.new(location.add_character(7), dash_rocket_node, [parameter_node], body_node) }

    let(:assignment) { expressions.first }
    let(:assignee) { assignment.reference }
    let(:value) { assignment.value }

    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
    end

    it 'finds the assignment' do
      expect(assignment).to eq(assignment_node)
    end

    it 'assigns to the == property' do
      expect(assignee).to eq(property_node)
    end

    it 'assigns a lambda' do
      expect(value).to eq(lambda_node)
    end
  end

  shared_examples_for 'invocation' do
    it 'has one top-level node' do
      expect(expressions.count).to eq(1)
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

    let(:property_node_plus) { Rip::Nodes::Property.new(location.add_character(2), one_node, '+') }
    let(:invocation_node_plus) { Rip::Nodes::Invocation.new(location.add_character(3), property_node_plus, [two_node]) }

    let(:property_node_times) { Rip::Nodes::Property.new(location.add_character(7), invocation_node_plus, '*') }
    let(:invocation_node_times) { Rip::Nodes::Invocation.new(location.add_character(8), property_node_times, [three_node]) }

    let(:invocation_times) { expressions.first }
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

    let(:invocation_times) { expressions.first }
    let(:invocation_plus) { invocation_times.callable.object }

    it_behaves_like 'invocation'
  end
end
