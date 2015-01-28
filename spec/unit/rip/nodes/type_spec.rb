require 'spec_helper'

describe Rip::Nodes::Type do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.new }

  let(:statements) { ast.body.statements }

  let(:populated_context) do
    context.nested_context.tap do |_context|
      statements.each { |statement| statement.interpret(_context) }
    end
  end

  describe '#interpret' do
    let(:ast) do
      build_ast(<<-RIP)
        half-life = 20

        _type = type {
          number = half-life + 22
          alias = number
          alias_alias = self.alias
        }

        Person = type {
          self.@.age = 33
          @.age_alias = @.age
          population = 100
        }

        Color = type {
          brightness = Person.population
        }

        Outer = type {
          foo = 17
          Inner = type {
            foo = 71
            bar = half-life + 16
          }
        }
      RIP
    end

    let(:half_life_node) { Rip::Nodes::Reference.new(location, 'half-life') }
    let(:half_life) { half_life_node.interpret(populated_context) }

    let(:type_node) { Rip::Nodes::Reference.new(location, '_type') }
    let(:type) { type_node.interpret(populated_context) }

    let(:person_node) { Rip::Nodes::Reference.new(location, 'Person') }
    let(:person) { person_node.interpret(populated_context) }

    let(:color_node) { Rip::Nodes::Reference.new(location, 'Color') }
    let(:color) { color_node.interpret(populated_context) }

    let(:outer_node) { Rip::Nodes::Reference.new(location, 'Outer') }
    let(:outer) { outer_node.interpret(populated_context) }

    let(:inner_node) { Rip::Nodes::Property.new(location, outer_node, 'Inner') }
    let(:inner) { inner_node.interpret(populated_context) }


    specify { expect(context.symbols).to eq([]) }
    specify { expect(populated_context.symbols).to match_array(['half-life', '_type', 'Person', 'Color', 'Outer']) }

    specify { expect(type.symbols).to match_array(['@', 'type', 'self', 'number', 'alias', 'alias_alias']) }
    specify { expect(type['number']).to eq(Rip::Core::Rational.integer(42)) }
    specify { expect(type['alias']).to be(type['number']) }
    specify { expect(type['alias_alias']).to be(type['alias']) }

    specify { expect(person.symbols).to match_array(['@', 'type', 'self', 'population']) }
    specify { expect(person['population']).to eq(Rip::Core::Rational.integer(100)) }

    specify { expect(person['@'].symbols).to match_array(['age', 'age_alias']) }
    specify { expect(person['@']['age_alias']).to be(person['@']['age']) }

    specify { expect(color.symbols).to match_array(['@', 'type', 'self', 'brightness']) }
    specify { expect(color['brightness']).to be(person['population']) }

    specify { expect(outer.symbols).to match_array(['@', 'type', 'self', 'foo', 'Inner']) }
    specify { expect(outer['foo']).to eq(Rip::Core::Rational.integer(17)) }

    specify { expect(inner.symbols).to match_array(['@', 'type', 'self', 'foo', 'bar']) }
    specify { expect(inner['foo']).to eq(Rip::Core::Rational.integer(71)) }
    specify { expect(inner['bar']).to eq(Rip::Core::Rational.integer(36)) }
  end
end
