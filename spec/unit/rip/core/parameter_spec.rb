require 'spec_helper'

describe Rip::Core::Parameter do
  let(:context) { Rip::Utilities::Scope.new }

  let(:name) { 'arg' }
  let(:type) { Rip::Core::Object.class_instance }
  let(:parameter) { Rip::Core::Parameter.new(name, type) }

  let(:forty_two) { Rip::Core::Integer.new(42) }

  describe '#bind' do
    before(:each) { parameter.bind(context, forty_two) }

    specify { expect(context.symbols).to include(name) }
    specify { expect(context[name]).to eq(forty_two) }
  end

  describe '#matches?' do
    specify do
      [
        [ Rip::Core::Object.class_instance, Rip::Core::Object.class_instance, true ],
        [ Rip::Core::Object.class_instance, Rip::Core::Class.class_instance, true ],
        [ Rip::Core::Object.class_instance, Rip::Core::Lambda.class_instance, true ],
        [ Rip::Core::Object.class_instance, Rip::Core::Integer.class_instance, true ],

        [ Rip::Core::Class.class_instance, Rip::Core::Object.class_instance, false ],
        [ Rip::Core::Class.class_instance, Rip::Core::Class.class_instance, true ],
        [ Rip::Core::Class.class_instance, Rip::Core::Lambda.class_instance, false ],
        [ Rip::Core::Class.class_instance, Rip::Core::Integer.class_instance, false ],

        [ Rip::Core::Integer.class_instance, Rip::Core::List.class_instance, false ],
        [ Rip::Core::List.class_instance, Rip::Core::String.class_instance, true ],
        [ Rip::Core::String.class_instance, Rip::Core::List.class_instance, false ]
      ].each do |(parameter_type, argument_type, expected)|
        parameter = Rip::Core::Parameter.new(name, parameter_type)

        expect(parameter.matches?(argument_type)).to be(expected)
      end
    end
  end
end
