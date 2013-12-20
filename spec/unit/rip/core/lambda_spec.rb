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
  end
end
