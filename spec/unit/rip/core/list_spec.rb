require 'spec_helper'

describe Rip::Core::List do
  let(:context) { Rip::Utilities::Scope.new }

  let(:class_instance) { Rip::Core::List.class_instance }

  let(:objects) { [] }
  let(:list) { Rip::Core::List.new(objects) }

  include_examples 'debug methods' do
    let(:class_to_s) { '#< System.List >' }

    let(:instance) { list }
    let(:instance_to_s) { '#< #< System.List > [ +, <<, class, filter, fold, head, length, map, reverse, tail, to_string ] items = [  ] >' }
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

    describe '@.head' do
      specify { expect(list['head']).to eq(Rip::Core::Integer.new(1)) }
    end

    describe '@.tail' do
      let(:expected) do
        Rip::Core::List.new([
          Rip::Core::Integer.new(2),
          Rip::Core::Integer.new(3)
        ])
      end

      specify { expect(list['tail']).to eq(expected) }
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

  describe '@.filter' do
    let(:objects) do
      [
        Rip::Core::Integer.new(1),
        Rip::Core::Integer.new(2),
        Rip::Core::Integer.new(3)
      ]
    end

    specify { expect(list['filter']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:sieve) do
        overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('n', Rip::Core::Integer.class_instance)
        ]) do |_context|
          Rip::Core::Boolean.from_native(_context['n'].data.even?)
        end
        Rip::Core::Lambda.new(context, [ overload ])
      end

      let(:expected_items) do
        [
          Rip::Core::Integer.new(2)
        ]
      end

      specify { expect(list['filter'].call([ sieve ])).to eq(Rip::Core::List.new(expected_items)) }
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
