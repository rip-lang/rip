require 'spec_helper'

describe Rip::Nodes::Character do
  let(:location) { location_for }

  let(:empty_scope) { Rip::Utilities::Scope.new }

  let(:character_node) { Rip::Nodes::Character.new(location, 'c') }

  include_examples 'debug methods' do
    let(:class_instance) { Rip::Core::Character.class_instance }
    let(:class_to_s) { 'System.Character' }
    let(:class_inspect) { '#< System.Character >' }

    let(:instance) { Rip::Core::Character.new('c') }
    let(:instance_to_s) { '`c' }
    let(:instance_inspect) { '#< System.Character [ class ] data = `c >' }
  end

  describe '#interpret' do
    it 'returns a Rip object representing a character' do
      expect(character_node.interpret(empty_scope)).to eq(Rip::Core::Character.new('c'))
    end
  end
end
