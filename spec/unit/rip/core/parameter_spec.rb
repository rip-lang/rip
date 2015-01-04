require 'spec_helper'

describe Rip::Core::Parameter do
  let(:context) { Rip::Compiler::Scope.new }

  let(:name) { 'arg' }
  let(:type) { Rip::Core::Object.type_instance }
  let(:parameter) { Rip::Core::Parameter.new(name, type) }

  let(:forty_two) { Rip::Core::Rational.integer(42) }

  describe '#bind' do
    before(:each) { parameter.bind(context, forty_two) }

    specify { expect(context.symbols).to include(name) }
    specify { expect(context[name]).to eq(forty_two) }
  end

  describe '#matches?' do
    specify do
      [
        [ Rip::Core::Object.type_instance, Rip::Core::Object.type_instance, true ],
        [ Rip::Core::Object.type_instance, Rip::Core::Type.type_instance, true ],
        [ Rip::Core::Object.type_instance, Rip::Core::Lambda.type_instance, true ],
        [ Rip::Core::Object.type_instance, Rip::Core::Rational.type_instance, true ],

        [ Rip::Core::Type.type_instance, Rip::Core::Object.type_instance, false ],
        [ Rip::Core::Type.type_instance, Rip::Core::Type.type_instance, true ],
        [ Rip::Core::Type.type_instance, Rip::Core::Lambda.type_instance, false ],
        [ Rip::Core::Type.type_instance, Rip::Core::Rational.type_instance, false ],

        [ Rip::Core::Rational.type_instance, Rip::Core::List.type_instance, false ],
        [ Rip::Core::List.type_instance, Rip::Core::String.type_instance, true ],
        [ Rip::Core::String.type_instance, Rip::Core::List.type_instance, false ]
      ].each do |(parameter_type, argument_type, expected)|
        parameter = Rip::Core::Parameter.new(name, parameter_type)

        expect(parameter.matches?(argument_type)).to be(expected)
      end
    end
  end
end
