require 'spec_helper'

describe Rip::Core::List do
  let(:context) { Rip::Compiler::Scope.new }

  let(:type_instance) { Rip::Core::List.type_instance }

  let(:objects) { [] }
  let(:list) { Rip::Core::List.new(objects) }

  include_examples 'debug methods' do
    let(:type_to_s) { '#< System.List >' }

    let(:instance) { list }
    let(:instance_to_s) { '#< #< System.List > [ +, <<, filter, fold, head, length, map, reverse, tail, to_string, type ] items = [  ] >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
  end

  describe '@.type' do
    specify { expect(list['type']).to be(type_instance) }
  end

  context 'dynamically computed properties' do
    let(:objects) do
      [
        Rip::Core::Rational.integer(1),
        Rip::Core::Rational.integer(2),
        Rip::Core::Rational.integer(3)
      ]
    end

    describe '@.head' do
      specify { expect(list['head']).to eq(Rip::Core::Rational.integer(1)) }
    end

    describe '@.tail' do
      let(:expected) do
        Rip::Core::List.new([
          Rip::Core::Rational.integer(2),
          Rip::Core::Rational.integer(3)
        ])
      end

      specify { expect(list['tail']).to eq(expected) }
    end
  end

  describe '@.reverse' do
    let(:objects) do
      [
        Rip::Core::Rational.integer(1),
        Rip::Core::Rational.integer(10),
        Rip::Core::Rational.integer(100)
      ]
    end

    specify { expect(list['reverse']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:reverse_objects) do
        [
          Rip::Core::Rational.integer(100),
          Rip::Core::Rational.integer(10),
          Rip::Core::Rational.integer(1)
        ]
      end

      let(:reverse_list) { list['reverse'].call([]) }

      specify { expect(reverse_list).to eq(Rip::Core::List.new(reverse_objects)) }
    end
  end

  describe '@.filter' do
    let(:objects) do
      [
        Rip::Core::Rational.integer(1),
        Rip::Core::Rational.integer(2),
        Rip::Core::Rational.integer(3)
      ]
    end

    specify { expect(list['filter']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:sieve) do
        overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('n', Rip::Core::Rational.type_instance)
        ]) do |_context|
          Rip::Core::Boolean.from_native(_context['n'].data.numerator.even?)
        end
        Rip::Core::Lambda.new(context, [ overload ])
      end

      let(:expected_items) do
        [
          Rip::Core::Rational.integer(2)
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
      let(:expected) { '[ (1 / 1), (2 / 1), (3 / 1) ]' }

      specify { expect(actual.to_native).to eq(expected) }
    end
  end
end
