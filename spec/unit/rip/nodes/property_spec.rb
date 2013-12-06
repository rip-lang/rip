require 'spec_helper'

describe Rip::Nodes::Property do
  let(:location) { location_for }

  let(:character_node) { Rip::Nodes::Character.new(location, 'c') }
  let(:property_node) { Rip::Nodes::Property.new(location, character_node, 'rip') }

  let(:context) { Rip::Utilities::Scope.new }

  describe '#interpret' do
    context 'unknown property name' do
      let(:property_node) { Rip::Nodes::Property.new(location, character_node, 'not-rip') }

      it 'raises an exception for invalid reference' do
        expect { property_node.interpret(context) }.to raise_error(Rip::Exceptions::RuntimeException)
      end

      it 'describes the problem when invalid reference' do
        actual = begin
          property_node.interpret(context)
        rescue => e
          e.message
        end

        expect(actual).to eq('Unknown property `not-rip`')
      end
    end
  end
end
