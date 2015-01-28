require 'spec_helper'

describe Rip::Nodes::List do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.new }

  let(:list_item_nodes) { [] }
  let(:list_node) { Rip::Nodes::List.new(location, list_item_nodes) }

  describe '#interpret' do
    it 'returns a Rip object representing a list' do
      expect(list_node.interpret(context)).to eq(Rip::Core::List.new([]))
    end

    context 'non-empty list' do
      let(:list_item_nodes) do
        [
          Rip::Nodes::Integer.new(location, 1),
          Rip::Nodes::Integer.new(location, 2),
          Rip::Nodes::Integer.new(location, 3)
        ]
      end

      let(:integers) do
        [
          Rip::Core::Rational.integer(1),
          Rip::Core::Rational.integer(2),
          Rip::Core::Rational.integer(3)
        ]
      end

      it 'returns a Rip object representing a list' do
        expect(list_node.interpret(context)).to eq(Rip::Core::List.new(integers))
      end
    end
  end
end
