require 'spec_helper'

describe Rip::Core::List do
  let(:context) { Rip::Utilities::Scope.new }

  let(:class_instance) { Rip::Core::List.class_instance }

  let(:objects) { [] }
  let(:list) { Rip::Core::List.new(objects) }

  include_examples 'debug methods' do
    let(:class_to_s) { '#< System.List >' }

    let(:instance) { list }
    let(:instance_to_s) { '#< #< System.List > [ <<, class, head, head_left, head_right, inject, join, next, reverse, tail, tail_left, tail_right, to_string ] items = [  ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(list['class']).to be(class_instance) }
  end

  context 'dynamically computed properties' do
    let(:objects) do
      [
        Rip::Core::Integer.new(1),
        Rip::Core::Integer.new(2),
        Rip::Core::Integer.new(3)
      ]
    end

    describe '@.head_left' do
      specify { expect(list['head_left']).to eq(Rip::Core::Integer.new(1)) }

      describe '@.head' do
        specify { expect(list['head']).to be(list['head_left']) }
      end
    end

    describe '@.head_right' do
      specify { expect(list['head_right']).to eq(Rip::Core::Integer.new(3)) }
    end

    describe '@.tail_left' do
      let(:expected) do
        Rip::Core::List.new([
          Rip::Core::Integer.new(2),
          Rip::Core::Integer.new(3)
        ])
      end

      specify { expect(list['tail_left']).to eq(expected) }

      describe '@.tail' do
        specify { expect(list['tail']).to be(list['tail_left']) }
      end
    end

    describe '@.tail_right' do
      let(:expected) do
        Rip::Core::List.new([
          Rip::Core::Integer.new(2),
          Rip::Core::Integer.new(1)
        ])
      end

      specify { expect(list['tail_right']).to eq(expected) }
    end
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

      let(:reverse_list) { list['reverse'].call([]) }

      specify { expect(reverse_list).to eq(Rip::Core::List.new(reverse_objects)) }
    end
  end

  describe '@.to_string' do
    let(:actual) { Rip.interpret(rip)['to_string'].call([]) }

    context 'empty list' do
      let(:rip) { '[]' }
      let(:expected) { '[ ]' }

      specify { expect(actual.to_native).to eq(expected) }
    end

    context 'non-empty list' do
      let(:rip) { '[1, 2, 3]' }
      let(:expected) { '[ 1, 2, 3 ]' }

      specify { expect(actual.to_native).to eq(expected) }
    end
  end
end
