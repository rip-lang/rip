require 'spec_helper'

BinaryOperator = Struct.new(:lhs, :operator, :rhs, :result)

describe Rip::Core::Integer do
  let(:context) { Rip::Utilities::Scope.new }

  let(:forty_two) { Rip::Core::Integer.new(42) }
  let(:class_instance) { Rip::Core::Integer.class_instance }

  include_examples 'debug methods' do
    let(:class_to_s) { '#< System.Integer >' }

    let(:instance) { forty_two }
    let(:instance_to_s) { '#< #< System.Integer > [ %, *, +, -, /, class ] data = 42 >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(forty_two['class']).to be(class_instance) }
  end

  describe '@.to_boolean' do
    let(:zero) { Rip::Core::Integer.new(0) }

    specify { expect(zero['to_boolean'].call([])).to eq(Rip::Core::Boolean.true) }
  end

  [
    BinaryOperator.new(11, :+, 22, 33),
    BinaryOperator.new(62, :+, -73, -11),
    BinaryOperator.new(-85, :+, 39, -46),
    BinaryOperator.new(-65, :+, -20, -85),

    BinaryOperator.new(-14, :-, -20, 6),
    BinaryOperator.new(-17, :-, 96, -113),
    BinaryOperator.new(0, :-, 30, -30),
    BinaryOperator.new(86, :-, 26, 60),

    BinaryOperator.new(73, :*, 87, 6351),
    BinaryOperator.new(8, :*, 96, 768),
    BinaryOperator.new(54, :*, -95, -5130),
    BinaryOperator.new(-4, :*, -8, 32),

    BinaryOperator.new(9, :/, 2, 4),
    BinaryOperator.new(8, :/, 4, 2),
    BinaryOperator.new(0, :/, 62, 0),
    BinaryOperator.new(72, :/, -4, -18),
    BinaryOperator.new(-30, :/, -5, 6),

    BinaryOperator.new(1, :%, -77, -76),
    BinaryOperator.new(-62, :%, -4, -2),
    BinaryOperator.new(-57, :%, -17, -6),
    BinaryOperator.new(-15, :%, -53, -15)
  ].each do |bo|
    describe "@.#{bo.operator}" do
      let(:lhs_node) { Rip::Nodes::Integer.new(nil, bo.lhs) }
      let(:operator_node) { Rip::Nodes::Property.new(nil, lhs_node, bo.operator) }
      let(:rhs_node) { Rip::Nodes::Integer.new(nil, bo.rhs) }
      let(:invocation_node) { Rip::Nodes::Invocation.new(nil, operator_node, [ rhs_node ]) }

      specify { expect(operator_node.interpret(context)['@']).to eq(lhs_node.interpret(context)) }
      specify { expect(invocation_node.interpret(context)).to eq(Rip::Core::Integer.new(bo.result)) }

      specify { expect(Rip::Core::Integer.new(bo.lhs)[bo.operator].call([ Rip::Core::Integer.new(bo.rhs) ])).to eq(Rip::Core::Integer.new(bo.result)) }
    end
  end
end
