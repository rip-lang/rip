require 'spec_helper'

describe Rip::Core::List do
  let(:context) { Rip::Utilities::Scope.new }

  let(:class_instance) { Rip::Core::List.class_instance }

  let(:objects) { [] }
  let(:list) { Rip::Core::List.new(objects) }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.List' }
    let(:class_inspect) { '#< System.List >' }

    let(:instance) { list }
    let(:instance_to_s) { '[]' }
    let(:instance_inspect) { '#< System.List [ class, reverse ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(list['class']).to be(class_instance) }
  end

  describe '@.reverse' do
    let(:objects) do
      [
        Rip::Core::Integer.new(1),
        Rip::Core::Integer.new(10),
        Rip::Core::Integer.new(100)
      ]
    end

    specify { expect(list['reverse']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:reverse_objects) do
        [
          Rip::Core::Integer.new(100),
          Rip::Core::Integer.new(10),
          Rip::Core::Integer.new(1)
        ]
      end

      let(:reverse_list) { list['reverse'].call(context, []) }

      specify { expect(reverse_list).to eq(Rip::Core::List.new(reverse_objects)) }
    end
  end
end
