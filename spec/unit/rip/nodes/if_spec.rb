require 'spec_helper'

describe Rip::Nodes::If do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Driver.global_context.nested_context }

  let(:true_body) { Rip::Nodes::BlockBody.new(location, true_body_nodes) }
  let(:false_body) { Rip::Nodes::BlockBody.new(location, false_body_nodes) }

  let(:if_node) { Rip::Nodes::If.new(location, argument, true_body, false_body) }

  describe '#interpret' do
    let(:true_body_nodes) do
      [ Rip::Nodes::Integer.new(location, 5) ]
    end

    let(:false_body_nodes) do
      [ Rip::Nodes::Integer.new(location, 10) ]
    end

    context 'argument is true' do
      let(:argument) { Rip::Nodes::Reference.new(location, 'true') }

      specify { expect(if_node.interpret(context)).to eq(Rip::Core::Integer.new(5)) }
    end

    context 'argument is false' do
      let(:argument) { Rip::Nodes::Reference.new(location, 'false') }

      specify { expect(if_node.interpret(context)).to eq(Rip::Core::Integer.new(10)) }
    end

    context 'argument is converted to boolean' do
      let(:argument) { Rip::Nodes::Integer.new(location, 0) }

      specify { expect(if_node.interpret(context)).to eq(Rip::Core::Integer.new(5)) }
    end
  end
end
