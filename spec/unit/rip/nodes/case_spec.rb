require 'spec_helper'

describe Rip::Nodes::Case do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.global_context.nested_context }

  let(:case_body_nodes) { [] }

  let(:case_node) do
    Rip::Nodes::Case.new(location, arguments, case_body_nodes)
  end

  describe '#matches?' do
    context 'single argument' do
      let(:arguments) do
        [
          Rip::Nodes::Reference.new(location, 'true')
        ]
      end

      it 'checks arguments for a match' do
        expect(case_node.matches?(context, Rip::Core::Boolean.true)).to be(true)
        expect(case_node.matches?(context, Rip::Core::Boolean.false)).to be(false)
      end
    end

    context 'multiple arguments' do
      let(:arguments) do
        [
          Rip::Nodes::Reference.new(location, 'false'),
          Rip::Nodes::Reference.new(location, 'true')
        ]
      end

      it 'matches even if only one argument matches' do
        expect(case_node.matches?(context, Rip::Core::Boolean.true)).to be(true)
      end
    end
  end
end
