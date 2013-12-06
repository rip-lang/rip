require 'spec_helper'

describe Rip::Nodes::BlockBody do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Utilities::Scope.new }

  let(:block_node) { Rip::Nodes::BlockBody.new(location, expression_nodes) }

  describe '#interpret' do
    let(:expression_nodes) do
      [
        Rip::Nodes::Integer.new(location, 3),
        Rip::Nodes::Integer.new(location, 42)
      ]
    end

    it 'returns the last expression' do
      expect(block_node.interpret(empty_scope)).to eq(Rip::Core::Integer.new(42))
    end

    it 'doesn\'t cause side-effects on outer scope' do
      block_node.interpret(empty_scope)
      expect(empty_scope).to eq(Rip::Utilities::Scope.new)
    end
  end
end
