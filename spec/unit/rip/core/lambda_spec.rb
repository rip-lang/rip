require 'spec_helper'

describe Rip::Core::Lambda do
  let(:type_instance) { Rip::Core::Lambda.type_instance }

  let(:location) { location_for }
  let(:context) { Rip::Compiler::Scope.new }

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
    let(:type_to_s) { '#< System.Lambda >' }

    let(:instance) { rip_lambda }
    let(:instance_to_s) { '#< #< System.Lambda > [ apply, bind, to_string, type ] arity = [ 0 ] >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
  end

  describe '#arity' do
    context 'no parameters' do
      specify { expect(rip_lambda.arity).to eq([ 0 ]) }
      specify { expect(rip_lambda.to_s).to eq('#< #< System.Lambda > [ apply, bind, to_string, type ] arity = [ 0 ] >') }
    end

    context 'all required parameters' do
      let(:parameters) do
        [
          Rip::Core::Parameter.new('a', Rip::Core::Integer.type_instance),
          Rip::Core::Parameter.new('b', Rip::Core::Integer.type_instance)
        ]
      end
      specify { expect(rip_lambda.arity).to eq([ 2 ]) }
      specify { expect(rip_lambda.to_s).to eq('#< #< System.Lambda > [ apply, bind, to_string, type ] arity = [ 2 ] >') }
    end
  end

  describe '@.type' do
    specify { expect(rip_lambda['type']).to be(type_instance) }
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
            Rip::Core::Parameter.new('answer', Rip::Core::Integer.type_instance)
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
          Rip::Core::Parameter.new('a', Rip::Core::Integer.type_instance),
          Rip::Core::Parameter.new('b', Rip::Core::Integer.type_instance),
          Rip::Core::Parameter.new('c', Rip::Core::Integer.type_instance)
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
          Rip::Core::Parameter.new('a', Rip::Core::Integer.type_instance),
          Rip::Core::Parameter.new('b', Rip::Core::Integer.type_instance),
          Rip::Core::Parameter.new('c', Rip::Core::Integer.type_instance)
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

  describe '@.apply' do
    let(:lambda_context) do
      context.nested_context.tap do |reply|
        reply['bar'] = bar
      end.nested_context
    end

    let(:bar) { Rip::Core::Integer.new(42) }
    let(:a) { Rip::Core::Integer.new(111) }
    let(:b) { Rip::Core::Integer.new(222) }
    let(:c) { Rip::Core::Integer.new(333) }
    let(:sum) { Rip::Core::Integer.new(666) }

    let(:the_lambda) do
      overload_1 = Rip::Core::NativeOverload.new([
        Rip::Core::Parameter.new('a', Rip::Core::Integer.type_instance),
        Rip::Core::Parameter.new('b', Rip::Core::Integer.type_instance),
        Rip::Core::Parameter.new('c', Rip::Core::Integer.type_instance)
      ]) do |_context|
        a = _context['a']
        b = _context['b']
        c = _context['c']
        a['+'].call([ b ])['+'].call([ c ])
      end

      overload_2 = Rip::Core::NativeOverload.new([
        Rip::Core::Parameter.new('foo', Rip::Core::Integer.type_instance)
      ]) do |_context|
        foo = _context['foo']
        bar = _context['bar']
        foo['+'].call([ bar ])
      end

      Rip::Core::Lambda.new(lambda_context, [ overload_1, overload_2 ])
    end

    specify { expect(the_lambda['apply']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:apply_111) { the_lambda['apply'].call([ Rip::Core::List.new([ a ]) ]) }
      let(:apply_222) { apply_111['apply'].call([ Rip::Core::List.new([ b ]) ]) }
      let(:apply_333) { the_lambda['apply'].call([ Rip::Core::List.new([ a, b, c ]) ]) }

      it 'returns a lambda' do
        expect(apply_111).to be_a(Rip::Core::Lambda)
        expect(apply_222).to be_a(Rip::Core::Lambda)
        expect(apply_333).to be_a(Rip::Core::Lambda)
      end

      it 'only holds potential overloads' do
        expect(apply_111.overloads.count).to eq(2)
        expect(apply_222.overloads.count).to eq(1)
        expect(apply_333.overloads.count).to eq(1)
      end

      it 'computes the correct total' do
        expect(apply_111.call([ b, c ])).to eq(sum)
        expect(apply_222.call([ c ])).to eq(sum)
        expect(apply_333.call([ ])).to eq(sum)
      end

      it 'uses the original lambda context' do
        expect(apply_111.call([ ])).to eq(Rip::Core::Integer.new(153))
      end
    end
  end

  describe '@.bind' do
    let(:receiver) { Rip::Core::Integer.new(42) }

    let(:the_lambda) do
      overload = Rip::Core::NativeOverload.new([
      ]) do |_context|
        _context['@']['to_string'].call([])
      end
      Rip::Core::Lambda.new(context, [ overload ])
    end

    specify { expect(the_lambda['bind']).to be_a(Rip::Core::Lambda) }
    specify { expect { the_lambda['@'] }.to raise_error(Rip::Exceptions::RuntimeException) }

    context 'invocation' do
      let(:answer) { Rip::Core::Integer.new(42) }
      let(:language) { Rip::Core::String.from_native('Rip') }

      let(:bound_answer) { the_lambda['bind'].call([ answer ]) }
      let(:bound_language) { bound_answer['bind'].call([ language ]) }

      let(:bound_answer_parameter) { bound_answer.overloads.first.parameters.first }
      let(:bound_language_parameter) { bound_language.overloads.first.parameters.first }

      it 'returns a lambda' do
        expect(bound_answer).to be_a(Rip::Core::Lambda)
        expect(bound_language).to be_a(Rip::Core::Lambda)
      end

      it 'binds a receiver' do
        expect(bound_answer['@']).to be(answer)
        expect(bound_language['@']).to be(language)
      end

      it 'replaces receiver parameter without appending' do
        expect(bound_answer.overloads.first.parameters.count).to eq(1)
        expect(bound_language.overloads.first.parameters.count).to eq(1)
      end

      it 'sets the correct parameter type' do
        expect(bound_answer_parameter.type).to eq(Rip::Core::Integer.type_instance)
        expect(bound_language_parameter.type).to eq(Rip::Core::String.type_instance)
      end

      it 'uses the bound receiver' do
        expect(bound_answer.call([]).to_native).to eq('42')
        expect(bound_language.call([]).to_native).to eq('Rip')
      end
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
