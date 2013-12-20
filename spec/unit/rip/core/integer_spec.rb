require 'spec_helper'

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

  describe '@.+' do
    let(:context) { Rip::Utilities::Scope.new }

    let(:integer_11) { Rip::Nodes::Integer.new(nil, 11) }
    let(:integer_22) { Rip::Nodes::Integer.new(nil, 22) }
    let(:plus) { Rip::Nodes::Property.new(nil, integer_11, '+') }
    let(:invocation_node) { Rip::Nodes::Invocation.new(nil, plus, [ integer_22 ]) }

    let(:plus_lambda) { plus.interpret(context) }
    let(:eleven) { integer_11.interpret(context) }
    let(:thirty_three) { invocation_node.interpret(context) }

    specify { expect(plus_lambda['@']).to eq(eleven) }
    specify { expect(thirty_three).to eq(Rip::Core::Integer.new(33)) }
  end
end
