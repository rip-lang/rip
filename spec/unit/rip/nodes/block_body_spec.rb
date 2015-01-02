require 'spec_helper'

describe Rip::Nodes::BlockBody do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Compiler::Scope.new }

  let(:block_node) { Rip::Nodes::BlockBody.new(location, expression_nodes) }

  let(:forty_two_node) { Rip::Nodes::Integer.new(location, 42) }
  let(:three_node) { Rip::Nodes::Integer.new(location, 2) }
  let(:number_node) { Rip::Nodes::Reference.new(location, 'number') }
  let(:number_assignment_node) { Rip::Nodes::Assignment.new(location, number_node, three_node) }

  let(:expression_nodes) do
    [
      number_assignment_node,
      forty_two_node
    ]
  end

  describe '#interpret' do
    it 'returns the last expression' do
      expect(block_node.interpret(empty_scope)).to eq(Rip::Core::Rational.integer(42))
    end

    it 'doesn\'t cause side-effects on outer scope' do
      block_node.interpret(empty_scope)
      expect(empty_scope).to eq(Rip::Compiler::Scope.new)
    end

    it 'calls the block once for each statement' do
      counter = 0
      block_node.interpret(empty_scope) do |statement|
        counter = counter + 1
      end

      expect(counter).to eq(expression_nodes.count)
    end

    it 'maps statements to return value of the block' do
      last_value = block_node.interpret(empty_scope) do |statement|
        :foo
      end

      expect(last_value).to eq(:foo)
    end

    it 'interprets the statement if block returns nil' do
      last_value = block_node.interpret(empty_scope) do |statement|
      end

      expect(last_value).to eq(Rip::Core::Rational.integer(42))
    end
  end
end
