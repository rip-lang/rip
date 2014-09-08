require 'spec_helper'

describe Rip::Core::Lambda do
  let(:class_instance) { Rip::Core::Lambda.class_instance }

  let(:location) { location_for }
  let(:context) { Rip::Utilities::Scope.new }

  let(:parameters) { [] }
  let(:body_expressions) { [] }
  let(:body) { Rip::Nodes::BlockBody.new(location, body_expressions) }

  let(:overload) { Rip::Core::Overload.new(parameters, body) }
  let(:overloads) { [ overload ] }
  let(:rip_lambda) { Rip::Core::Lambda.new(context, overloads) }

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
    let(:class_to_s) { '#< System.Lambda >' }

    let(:instance) { rip_lambda }
    let(:instance_to_s) { '#< #< System.Lambda > [ class, to_string ] arity = [ 0 ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '#arity' do
    context 'no parameters' do
      specify { expect(rip_lambda.arity).to eq([ 0 ]) }
      specify { expect(rip_lambda.to_s).to eq('#< #< System.Lambda > [ class, to_string ] arity = [ 0 ] >') }
    end

    context 'all required parameters' do
      let(:parameters) do
        [
          Rip::Nodes::Parameter.new(location, 'a'),
          Rip::Nodes::Parameter.new(location, 'b')
        ]
      end
      specify { expect(rip_lambda.arity).to eq([ 2 ]) }
      specify { expect(rip_lambda.to_s).to eq('#< #< System.Lambda > [ class, to_string ] arity = [ 2 ] >') }
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

    describe 'automatic application' do
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
          Rip::Core::Integer.new(3)
        ]
      end

      it 'returns a lambda that takes one argument' do
        expect(actual_return).to be_a(Rip::Core::Lambda)
        expect(actual_return.overloads.count).to eq(1)
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
    end
  end

  describe '#bind' do
    let(:two) { Rip::Core::Integer.new(2) }
    let(:five) { Rip::Core::Integer.new(5) }
    let(:seven) { Rip::Core::Integer.new(7) }

    let!(:two_plus) { two['+'] }

    specify do
      expect(two_plus).to be_a(Rip::Core::Lambda)
    end

    it 'keeps a reference to the receiver' do
      expect(two_plus['@']).to eq(two)
    end

    it 'is callable' do
      expect(two_plus.call([ five ])).to eq(seven)
    end

    context 'when receiver is a lambda' do
      let(:rip) { '-> { 42 }' }
      let(:answer_lambda) { Rip.interpret(rip) }

      it 'has no receiver' do
        expect { answer_lambda['@'] }.to raise_error(Rip::Exceptions::RuntimeException)
      end

      it 'method\'s original receiver is returned' do
        expect(answer_lambda['to_string']['@']).to eq(answer_lambda)
      end

      it 'method\'s original receiver has no receiver' do
        expect { answer_lambda['to_string']['@']['@'] }.to raise_error(Rip::Exceptions::RuntimeException)
      end
    end
  end

  describe '@.bind', :blur do
    let(:body_expressions) do
      [ Rip::Nodes::Reference.new(location, '@') ]
    end

    let(:character) { Rip::Core::Character.new('c') }
    let(:bound_lambda) { rip_lambda['bind'].call([ character ]) }

    it 'has a receiver only if bound' do
      expect(rip_lambda.symbols).to_not include('@')
      expect(bound_lambda.symbols).to include('@')
    end

    it 'exposes its receiver' do
      expect(bound_lambda['@']).to eq(character)
    end

    it 'can return the receiver' do
      expect(bound_lambda.call(arguments)).to eq(character)
    end
  end

  describe '#call' do
    context do
      let(:body_expressions) do
        [ Rip::Nodes::Reference.new(location, 'self') ]
      end

      let(:two) { Rip::Core::Integer.new(2) }
      let(:two_plus) { two['+'] }

      specify { expect(rip_lambda.call(arguments)).to eq(rip_lambda) }
      specify { expect(two_plus.call(arguments)).to eq(two_plus) }
    end
  end

  describe '@.to_string' do
    let(:rip_lambda) { Rip.interpret(rip) }
    let(:actual) { rip_lambda['to_string'].call([]) }
    let(:expected) { Rip::Core::String.from_native(expected_native) }

    context 'single overload, no parameters' do
      let(:rip) do
        <<-RIP
-> { 42 }
        RIP
      end

      let(:expected_native) do
        <<-STRING
=> {
\t-> () { ... }
}
        STRING
      end

      specify { expect(actual.to_native).to eq(expected.to_native) }
    end

    context 'multiple overloads, yes parameters', :blur do
      let(:rip) do
        <<-RIP
=> {
  -> { 42 }
  -> (a) { 42 }
  -> (a, b<System.Integer>) { 42 }
}
        RIP
      end

      let(:expected_native) do
        <<-STRING
=> {
\t-> () { ... }
\t-> (a<System.Object>) { ... }
\t-> (a<System.Object>, b<System.Integer>) { ... }
}
        STRING
      end

      specify { expect(actual.to_native).to eq(expected.to_native) }
    end
  end
end
