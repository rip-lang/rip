require 'spec_helper'

describe Rip::Nodes::Class do
  let(:location) { location_for }

  let(:context) { Rip::Utilities::Scope.new }

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

        Klass = class {
          number = half-life + 22
          alias = number
          alias_alias = self.alias
        }

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

    let(:half_life_node) { Rip::Nodes::Reference.new(location, 'half-life') }
    let(:half_life) { half_life_node.interpret(populated_context) }

    let(:klass_node) { Rip::Nodes::Reference.new(location, 'Klass') }
    let(:klass) { klass_node.interpret(populated_context) }

    let(:person_node) { Rip::Nodes::Reference.new(location, 'Person') }
    let(:person) { person_node.interpret(populated_context) }

    let(:color_node) { Rip::Nodes::Reference.new(location, 'Color') }
    let(:color) { color_node.interpret(populated_context) }

    let(:outer_node) { Rip::Nodes::Reference.new(location, 'Outer') }
    let(:outer) { outer_node.interpret(populated_context) }

    let(:inner_node) { Rip::Nodes::Property.new(location, outer_node, 'Inner') }
    let(:inner) { inner_node.interpret(populated_context) }


    specify { expect(context.symbols).to eq([]) }
    specify { expect(populated_context.symbols).to match_array(['half-life', 'Klass', 'Person', 'Color']) }

    specify { expect(klass.symbols).to match_array(['@', 'class', 'self', 'number', 'alias', 'alias_alias']) }
    specify { expect(klass['number']).to eq(Rip::Core::Integer.new(42)) }
    specify { expect(klass['alias']).to be(klass['number']) }
    specify { expect(klass['alias_alias']).to be(klass['alias']) }

    specify { expect(person.symbols).to match_array(['@', 'class', 'self', 'population']) }
    specify { expect(person['population']).to eq(Rip::Core::Integer.new(100)) }

    specify { expect(person['@'].symbols).to match_array(['age', 'age_alias']) }
    specify { expect(person['@']['age_alias']).to be(person['@']['age']) }

    specify { expect(color.symbols).to match_array(['@', 'class', 'self', 'brightness']) }
    specify { expect(color['brightness']).to be(person['population']) }
  end
end
