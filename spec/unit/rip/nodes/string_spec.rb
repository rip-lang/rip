require 'spec_helper'

describe Rip::Nodes::String do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.new }

  let(:character_nodes) { [] }
  let(:string_node) { Rip::Nodes::String.new(location, character_nodes) }

  describe '#interpret' do
    it 'returns a Rip object representing a string' do
      expect(string_node.interpret(context)).to eq(Rip::Core::String.new([]))
    end

    context 'non-empty string' do
      let(:character_nodes) { rip_string_nodes(location, 'one') }
      let(:characters) do
        [
          Rip::Core::Character.new(:o),
          Rip::Core::Character.new(:n),
          Rip::Core::Character.new(:e)
        ]
      end

      it 'returns a Rip object representing a string' do
        expect(string_node.interpret(context)).to eq(Rip::Core::String.new(characters))
      end
    end
  end
end
