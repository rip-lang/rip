require 'spec_helper'

describe Rip::Nodes::Invocation do
  let(:location) { location_for }
  let(:context) { Rip::Utilities::Scope.new }

  let(:invocation_node) { Rip::Nodes::Invocation.new(location, callable_node, argument_nodes) }

  describe '#interpret' do
    let(:one_node) { Rip::Nodes::Integer.new(location, 1) }
    let(:callable_node) { Rip::Nodes::Property.new(location, one_node, '+') }
    let(:argument_nodes) { [ Rip::Nodes::Integer.new(location, 2) ] }

    specify { expect(invocation_node.interpret(context)).to eq(Rip::Core::Integer.new(3)) }
  end
end
