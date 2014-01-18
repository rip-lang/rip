require 'spec_helper'

describe Rip::Nodes::Class do
  let(:location) { location_for }

  let(:klass_superclasses) { [] }
  let(:klass_body_nodes) { [] }
  let(:klass_block_node) { Rip::Nodes::BlockBody.new(location, klass_body_nodes) }
  let(:klass_node) { Rip::Nodes::Class.new(location, klass_superclasses, klass_block_node) }

  let(:context) { Rip::Utilities::Scope.new }

  let(:interpreted_class) { klass_node.interpret(context) }

  describe '#interpret' do
    context 'empty class body' do
      let(:klass_body_nodes) { [] }

      specify { expect(interpreted_class).to eq(Rip::Core::Class.new) }
    end

    context 'assigning single class property' do
      # half-life = 20
      # class {
      #   number = half-life + 22
      #   alias = number
      # }

      let(:twenty_node) { Rip::Nodes::Integer.new(location, 20) }
      let(:twenty_two_node) { Rip::Nodes::Integer.new(location, 22) }

      let(:half_life_node) { Rip::Nodes::Reference.new(location, 'half-life') }
      let(:half_life_assignment_node) { Rip::Nodes::Assignment.new(location, half_life_node, twenty_node) }

      let(:plus_node) { Rip::Nodes::Property.new(location, half_life_node, '+') }
      let(:addition_node) { Rip::Nodes::Invocation.new(location, plus_node, [ twenty_two_node ]) }

      let(:number_node) { Rip::Nodes::Reference.new(location, 'number') }
      let(:number_assignment_node) { Rip::Nodes::Assignment.new(location, number_node, addition_node) }

      let(:alias_node) { Rip::Nodes::Reference.new(location, 'alias') }
      let(:alias_assignment_node) { Rip::Nodes::Assignment.new(location, alias_node, number_node) }

      let(:klass_body_nodes) do
        [
          number_assignment_node,
          alias_assignment_node
        ]
      end

      let(:klass) do
        klass_node.interpret(context)
      end

      before(:each) do
        half_life_assignment_node.interpret(context)
      end

      describe 'resulting symbols' do
        specify { expect(context.symbols).to match_array(['half-life']) }
        specify { expect(klass.symbols).to match_array(['@', 'class', 'number', 'alias']) }
      end

      describe 'retrieving class properties' do
        # klass.number
        # klass.alias

        let(:klass_number_node) { Rip::Nodes::Property.new(location, klass_node, number_node.name) }
        let(:klass_number) { klass_number_node.interpret(context) }

        let(:klass_alias_node) { Rip::Nodes::Property.new(location, klass_node, alias_node.name) }
        let(:klass_alias) { klass_alias_node.interpret(context) }

        specify { expect(klass_number).to eq(Rip::Core::Integer.new(42)) }
        specify { expect(klass_alias).to eq(Rip::Core::Integer.new(42)) }
      end
    end
  end
end
