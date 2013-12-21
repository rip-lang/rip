require 'spec_helper'

BinaryOperator = Struct.new(:lhs, :operator, :rhs, :result)

describe Rip::Core::Integer do
  let(:forty_two) { Rip::Core::Integer.new(42) }
  let(:class_instance) { Rip::Core::Integer.class_instance }

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(forty_two['class']).to be(class_instance) }
  end

  [
    BinaryOperator.new(11, :+, 22, 33)
  ].each do |bo|
    describe "@.#{bo.operator}" do
      let(:context) { Rip::Utilities::Scope.new }

      let(:lhs_node) { Rip::Nodes::Integer.new(nil, bo.lhs) }
      let(:operator_node) { Rip::Nodes::Property.new(nil, lhs_node, bo.operator) }
      let(:rhs_node) { Rip::Nodes::Integer.new(nil, bo.rhs) }
      let(:invocation_node) { Rip::Nodes::Invocation.new(nil, operator_node, [ rhs_node ]) }

      specify { expect(operator_node.interpret(context)['@']).to eq(lhs_node.interpret(context)) }
      specify { expect(invocation_node.interpret(context)).to eq(Rip::Core::Integer.new(bo.result)) }
    end
  end
end
