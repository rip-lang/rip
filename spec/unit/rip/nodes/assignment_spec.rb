require 'spec_helper'

describe Rip::Nodes::Assignment do
  let(:location) { location_for }

  let(:context) { Rip::Utilities::Scope.new }
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
  end
end
