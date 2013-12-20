require 'spec_helper'

describe Rip::Core::Lambda do
  let(:class_instance) { Rip::Core::Lambda.class_instance }

  let(:location) { location_for }
  let(:context) { Rip::Utilities::Scope.new }

  let(:keyword) { Rip::Utilities::Keywords[:dash_rocket] }
  let(:parameters) { [] }
  let(:body_expressions) { [] }
  let(:body) { Rip::Nodes::BlockBody.new(location, body_expressions) }

  let(:rip_lambda) { Rip::Core::Lambda.new(context, keyword, parameters, body) }

  let(:arguments) { [] }

  let(:actual_return) { rip_lambda.call(context, arguments) }

  let(:a_plus_b_plus_c) do
    reference_a = Rip::Nodes::Reference.new(location, 'a')
    reference_b = Rip::Nodes::Reference.new(location, 'b')
    reference_c = Rip::Nodes::Reference.new(location, 'c')

    plus_a = Rip::Nodes::Property.new(location, reference_a, '+')
    a_plus_b = Rip::Nodes::Invocation.new(location, plus_a, [ reference_b ])

    a_plus_b_plus = Rip::Nodes::Property.new(location, a_plus_b, '+')
    Rip::Nodes::Invocation.new(location, a_plus_b_plus, [ reference_c ])
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(rip_lambda['class']).to be(class_instance) }
  end

  describe 'calling semantics' do
    describe 'capturing lexical scope' do
      before(:each) do
        context['answer'] = Rip::Core::Integer.new(42)
      end

      let(:body_expressions) do
        [
          Rip::Nodes::Reference.new(location, 'answer')
        ]
      end

      context 'accessing surrounding scope' do
        specify { expect(actual_return).to eq(Rip::Core::Integer.new(42)) }
      end

      context 'shadowing surrounding scope' do
        let(:parameters) do
          [
            Rip::Nodes::Reference.new(location, 'answer')
          ]
        end

        let(:arguments) do
          [
            Rip::Nodes::Integer.new(location, 85)
          ]
        end

        specify { expect(actual_return).to eq(Rip::Core::Integer.new(85)) }

        it 'does not mutate surrounding scope' do
          actual_return
          expect(context['answer']).to eq(Rip::Core::Integer.new(42))
        end
      end
    end

    describe 'returning final expression' do
      let(:body_expressions) do
        [
          Rip::Nodes::Integer.new(location, 10),
          Rip::Nodes::Integer.new(location, 4)
        ]
      end

      it 'returns the last expression' do
        expect(actual_return).to eq(Rip::Nodes::Integer.new(location, 4))
      end
    end

    describe 'required parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Reference.new(location, 'a'),
          Rip::Nodes::Reference.new(location, 'b'),
          Rip::Nodes::Reference.new(location, 'c')
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Nodes::Integer.new(location, 1),
          Rip::Nodes::Integer.new(location, 2),
          Rip::Nodes::Integer.new(location, 3)
        ]
      end

      it 'interprets to six' do
        expect(actual_return).to eq(Rip::Core::Integer.new(6))
      end
    end

    describe 'optional parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Reference.new(location, 'a'),
          Rip::Nodes::Assignment.new(location, Rip::Nodes::Reference.new(location, 'b'), Rip::Nodes::Integer.new(location, 2)),
          Rip::Nodes::Assignment.new(location, Rip::Nodes::Reference.new(location, 'c'), Rip::Nodes::Integer.new(location, 3))
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Nodes::Integer.new(location, 3),
          Rip::Nodes::Integer.new(location, 3)
        ]
      end

      it 'interprets to nine' do
        expect(actual_return).to eq(Rip::Core::Integer.new(9))
      end
    end

    describe 'automatic currying' do
      let(:parameters) do
        [
          Rip::Nodes::Reference.new(location, 'a'),
          Rip::Nodes::Reference.new(location, 'b'),
          Rip::Nodes::Assignment.new(location, Rip::Nodes::Reference.new(location, 'c'), Rip::Nodes::Integer.new(location, 3))
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Nodes::Integer.new(location, 3)
        ]
      end

      it 'returns a lambda that takes two parameters' do
        expect(actual_return).to be_a(Rip::Core::Lambda)
        expect(actual_return.parameters.count).to be(2)
      end

      it 'remembers the arguments previously passed in' do
        other_arguments = [
          Rip::Nodes::Integer.new(location, 3),
          Rip::Nodes::Integer.new(location, 3)
        ]
        expect(actual_return.call(context, other_arguments)).to eq(Rip::Core::Integer.new(9))
      end

      it 'can be called with different arguments' do
        other_arguments = [
          Rip::Nodes::Integer.new(location, 8),
          Rip::Nodes::Integer.new(location, 16)
        ]
        expect(actual_return.call(context, other_arguments)).to eq(Rip::Core::Integer.new(27))
      end

      it 'can still use default values for optional arguments' do
        other_arguments = [
          Rip::Nodes::Integer.new(location, 8)
        ]
        expect(actual_return.call(context, other_arguments)).to eq(Rip::Core::Integer.new(14))
      end
    end
  end
end
