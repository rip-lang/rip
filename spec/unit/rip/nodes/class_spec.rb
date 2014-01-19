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
        specify { expect(klass.symbols).to match_array(['@', 'class', 'self', 'number', 'alias']) }
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

      describe 'assigning class property with explicit `self`' do
        # inside class definition...
        # self.foo = 1
        # bar = self.foo

        let(:one_node) { Rip::Nodes::Integer.new(location, 1) }

        let(:self_node) { Rip::Nodes::Reference.new(location, 'self') }
        let(:foo_node) { Rip::Nodes::Reference.new(location, 'foo') }
        let(:self_foo_node) { Rip::Nodes::Property.new(location, self_node, foo_node.name) }
        let(:self_foo_assignment_node) { Rip::Nodes::Assignment.new(location, self_foo_node, one_node) }

        let(:bar_node) { Rip::Nodes::Reference.new(location, 'bar') }
        let(:bar_assignment_node) { Rip::Nodes::Assignment.new(location, bar_node, self_foo_node) }

        let(:klass_body_nodes) do
          [
            self_foo_assignment_node,
            bar_assignment_node
          ]
        end

        describe 'resulting symbols' do
          specify { expect(klass.symbols).to match_array(['@', 'class', 'self', 'foo', 'bar']) }
        end

        describe 'retrieving class properties' do
          # klass.foo

          let(:klass_foo_node) { Rip::Nodes::Property.new(location, klass_node, foo_node.name) }
          let(:klass_foo) { klass_foo_node.interpret(context) }

          specify { expect(klass_foo).to eq(Rip::Core::Integer.new(1)) }
        end
      end
    end

    describe 'accessing global property' do
      let(:ast) do
        build_ast(<<-RIP)
          Person = class {
            self.@.age = 33
            @.age_alias = @.age
            population = 100
          }
          Color = class {
            brightness = Person.population
          }
        RIP
      end

      let(:statements) { ast.body.statements }

      let(:populated_context) do
        _context = context.nested_context

        statements.each do |statement|
          statement.interpret(_context)
        end

        _context
      end

      let(:person_node) { Rip::Nodes::Reference.new(location, 'Person') }
      let(:color_node) { Rip::Nodes::Reference.new(location, 'Color') }

      let(:person) { person_node.interpret(populated_context) }
      let(:color) { color_node.interpret(populated_context) }

      specify { expect(populated_context.symbols).to match_array(['Person', 'Color']) }

      specify { expect(person.symbols).to include('population') }
      specify { expect(person['population']).to eq(Rip::Core::Integer.new(100)) }

      specify { expect(person['@'].symbols).to match_array(['age', 'age_alias']) }
      specify { expect(person['@']['age_alias']).to eq(person['@']['age']) }

      specify { expect(color.symbols).to include('brightness') }
      specify { expect(color['brightness']).to be(person['population']) }
    end
  end
end
