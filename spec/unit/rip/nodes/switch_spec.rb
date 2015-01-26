require 'spec_helper'

describe Rip::Nodes::Switch do
  let(:location) { location_for }

  let(:context) do
    Rip::Compiler::Scope.global_context.nested_context.tap do |reply|
      reply['foo'] = Rip::Core::Boolean.true
    end
  end

  let(:case_arguments) do
    [
      Rip::Nodes::Reference.new(location, 'foo')
    ]
  end
  let(:case_body_nodes) do
    Rip::Nodes::BlockBody.new(location, [
      Rip::Nodes::Integer.new(location, 42)
    ])
  end
  let(:case_node) do
    Rip::Nodes::Case.new(location, case_arguments, case_body_nodes)
  end

  let(:else_body_nodes) do
    Rip::Nodes::BlockBody.new(location, [
      Rip::Nodes::Integer.new(location, 0)
    ])
  end
  let(:else_node) do
    Rip::Nodes::Else.new(location, else_body_nodes)
  end

  let(:switch_node) do
    Rip::Nodes::Switch.new(location, switch_argument, [ case_node ], else_node)
  end

  describe '#interpret' do
    context 'a case matches' do
      let(:switch_argument) { Rip::Nodes::Reference.new(location, 'true') }

      it 'interprets the matching case' do
        expect(switch_node.interpret(context)).to eq(Rip::Core::Rational.integer(42))
      end
    end

    context 'a case fails to match' do
      let(:switch_argument) { Rip::Nodes::Reference.new(location, 'false') }

      it 'interprets the else block' do
        expect(switch_node.interpret(context)).to eq(Rip::Core::Rational.integer(0))
      end
    end

    context 'no argument for switch' do
      let(:switch_argument) { nil }

      it 'interprets the first case that matches true' do
        expect(switch_node.interpret(context)).to eq(Rip::Core::Rational.integer(42))
      end
    end
  end
end
