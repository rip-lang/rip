require 'spec_helper'

describe Rip::Nodes::Character do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Compiler::Scope.new }

  let(:character_node) { Rip::Nodes::Character.new(location, 'c') }

  describe '#interpret' do
    it 'returns a Rip object representing a character' do
      expect(character_node.interpret(empty_scope)).to eq(Rip::Core::Character.new('c'))
    end
  end
end
