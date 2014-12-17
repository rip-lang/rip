require 'spec_helper'

describe Rip::Nodes::Decimal do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Compiler::Scope.new }

  let(:decimal_node) { Rip::Nodes::Decimal.new(location, '3.14') }

  describe '#interpret' do
    it 'returns a Rip object representing a number' do
      expect(decimal_node.interpret(empty_scope)).to eq(Rip::Core::Rational.new(314, 100))
    end
  end
end
