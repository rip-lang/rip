require 'spec_helper'

describe Rip::Core::Class do
  let(:klass) { Rip::Core::Class.new }
  let(:class_instance) { Rip::Core::Class.class_instance }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.Class' }
    let(:class_inspect) { '#< System.Class >' }

    let(:instance) { klass }
    let(:instance_to_s) { '#< System.Class [ @, class ] >' }
    let(:instance_inspect) { '#< System.Class [ @, class ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to be(Rip::Core::Class.class_instance) }
  end

  describe '#resolve' do
    let(:context) { Rip::Utilities::Scope.new }

    let(:question_node) { Rip::Nodes::Reference.new(location_for, 'question') }
    let(:answer_node) { Rip::Nodes::Reference.new(location_for, 'answer') }

    before(:each) do
      context[question_node.name] = Rip::Core::Integer.new(24)
      klass[answer_node.name] = Rip::Core::Integer.new(42)
    end

    specify { expect { klass.resolve(context, question_node) }.to raise_error(Rip::Exceptions::RuntimeException) }

    specify { expect(klass.resolve(context, answer_node)).to eq(Rip::Core::Integer.new(42)) }
  end

  describe '@.@' do
    specify { expect(klass['@']).to eq(Rip::Core::Prototype.new) }
  end

  describe '@.class' do
    specify { expect(klass['class']).to eq(class_instance) }
  end
end
