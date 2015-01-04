require 'spec_helper'

describe Rip::Nodes::Module do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Compiler::Scope.new }

  let(:block_node) { Rip::Nodes::BlockBody.new(location, expression_nodes) }
  let(:module_node) { Rip::Nodes::Module.new(location, block_node) }

  describe '#interpret' do
    let(:expression_nodes) do
      [
        Rip::Nodes::Integer.new(location, 3),
        Rip::Nodes::Integer.new(location, 42)
      ]
    end

    it 'returns the last expression' do
      expect(module_node.interpret(empty_scope)).to eq(Rip::Core::Rational.integer(42))
    end
  end
end
