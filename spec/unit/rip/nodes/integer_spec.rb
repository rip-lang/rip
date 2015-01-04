require 'spec_helper'

describe Rip::Nodes::Integer do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Compiler::Scope.new }

  let(:integer_node) { Rip::Nodes::Integer.new(location, 42) }

  describe '#interpret' do
    it 'returns a Rip object representing a number' do
      expect(integer_node.interpret(empty_scope)).to eq(Rip::Core::Rational.integer(42))
    end
  end
end
