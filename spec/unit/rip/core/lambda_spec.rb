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

  let(:actual_return) { rip_lambda.call(arguments) }

  let(:a_plus_b_plus_c) do
    reference_a = Rip::Nodes::Reference.new(location, 'a')
    reference_b = Rip::Nodes::Reference.new(location, 'b')
    reference_c = Rip::Nodes::Reference.new(location, 'c')

    plus_a = Rip::Nodes::Property.new(location, reference_a, '+')
    a_plus_b = Rip::Nodes::Invocation.new(location, plus_a, [ reference_b ])

    a_plus_b_plus = Rip::Nodes::Property.new(location, a_plus_b, '+')
    Rip::Nodes::Invocation.new(location, a_plus_b_plus, [ reference_c ])
  end

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.Lambda' }
    let(:class_inspect) { '#< System.Lambda >' }

    let(:instance) { rip_lambda }
    let(:instance_to_s) { '#< System.Lambda [ class ] keyword = ->, arity = 0 >' }
    let(:instance_inspect) { '#< System.Lambda [ class ] keyword = ->, arity = 0 >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '#arity' do
    context 'no parameters' do
      specify { expect(rip_lambda.arity).to eq(0) }
      specify { expect(rip_lambda.inspect).to eq('#< System.Lambda [ class ] keyword = ->, arity = 0 >') }
    end

    context 'all required parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b')
        ]
      end
      specify { expect(rip_lambda.arity).to eq(2) }
      specify { expect(rip_lambda.inspect).to eq('#< System.Lambda [ class ] keyword = ->, arity = 2 >') }
    end

    context 'all optional parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a', Rip::Nodes::Integer.new(location, 1)),
          Rip::Nodes::Parameter.new(location, 'b', Rip::Nodes::Integer.new(location, 2))
        ]
      end
      specify { expect(rip_lambda.arity).to eq(0..2) }
      specify { expect(rip_lambda.inspect).to eq('#< System.Lambda [ class ] keyword = ->, arity = 0..2 >') }
    end

    context 'mixed parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b', Rip::Nodes::Integer.new(location, 2))
        ]
      end
      specify { expect(rip_lambda.arity).to eq(1..2) }
      specify { expect(rip_lambda.inspect).to eq('#< System.Lambda [ class ] keyword = ->, arity = 1..2 >') }
    end
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
            Rip::Nodes::Parameter.new(location, 'answer')
          ]
        end

        let(:arguments) do
          [
            Rip::Core::Integer.new(85)
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
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b'),
          Rip::Nodes::Parameter.new(location, 'c')
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Core::Integer.new(1),
          Rip::Core::Integer.new(2),
          Rip::Core::Integer.new(3)
        ]
      end

      it 'interprets to six' do
        expect(actual_return).to eq(Rip::Core::Integer.new(6))
      end
    end

    describe 'optional parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b', Rip::Nodes::Integer.new(location, 2)),
          Rip::Nodes::Parameter.new(location, 'c', Rip::Nodes::Integer.new(location, 3))
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Core::Integer.new(3),
          Rip::Core::Integer.new(3)
        ]
      end

      it 'interprets to nine' do
        expect(actual_return).to eq(Rip::Core::Integer.new(9))
      end
    end

    describe 'automatic currying' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b'),
          Rip::Nodes::Parameter.new(location, 'c', Rip::Nodes::Integer.new(location, 3))
        ]
      end

      let(:body_expressions) { [ a_plus_b_plus_c ] }

      let(:arguments) do
        [
          Rip::Core::Integer.new(3)
        ]
      end

      it 'returns a lambda that takes two parameters' do
        expect(actual_return).to be_a(Rip::Core::Lambda)
        expect(actual_return.parameters.count).to eq(2)
      end

      it 'remembers the arguments previously passed in' do
        other_arguments = [
          Rip::Core::Integer.new(3),
          Rip::Core::Integer.new(3)
        ]
        expect(actual_return.call(other_arguments)).to eq(Rip::Core::Integer.new(9))
      end

      it 'can be called with different arguments' do
        other_arguments = [
          Rip::Core::Integer.new(8),
          Rip::Core::Integer.new(16)
        ]
        expect(actual_return.call(other_arguments)).to eq(Rip::Core::Integer.new(27))
      end

      it 'can still use default values for optional arguments' do
        other_arguments = [
          Rip::Core::Integer.new(8)
        ]
        expect(actual_return.call(other_arguments)).to eq(Rip::Core::Integer.new(14))
      end
    end
  end
end
