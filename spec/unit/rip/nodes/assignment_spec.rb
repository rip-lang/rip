require 'spec_helper'

describe Rip::Nodes::Assignment do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.new }
  let(:integer_node) { Rip::Nodes::Integer.new(location, 42) }

  describe '#interpret' do
    context 'assigning to a reference' do
      # foo = 42
      let(:reference_node) { Rip::Nodes::Reference.new(location, 'foo') }
      let(:assignment_node) { Rip::Nodes::Assignment.new(location, reference_node, integer_node) }
      before(:each) { assignment_node.interpret(context) }

      it 'assigns to local scope' do
        expect(context['foo']).to eq(integer_node)
      end

      it 'returns rhs when asked' do
        expect(reference_node.interpret(context)).to eq(integer_node)
      end
    end

    context 'assigning to a property' do
      # foo = `c
      let(:character_node) { Rip::Nodes::Character.new(location, 'c') }
      let(:character_reference) { Rip::Nodes::Reference.new(location, 'foo') }
      let(:reference_assignment) { Rip::Nodes::Assignment.new(location, character_reference, character_node) }
      before(:each) { reference_assignment.interpret(context) }

      # foo.bar = 42
      let(:property_node) { Rip::Nodes::Property.new(location, character_reference, 'bar') }
      let(:property_assignment) { Rip::Nodes::Assignment.new(location, property_node, integer_node) }
      before(:each) { property_assignment.interpret(context) }

      it 'assigns to object property' do
        expect(character_reference.interpret(context)['bar']).to eq(integer_node)
      end

      it 'returns the property when asked' do
        expect(property_node.interpret(context)).to eq(integer_node)
      end
    end
  end
end
