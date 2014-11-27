require 'spec_helper'

describe Rip::Core::Character do
  let(:location) { location_for }
  let(:context) { Rip::Compiler::Scope.new }

  let(:type_instance) { Rip::Core::Character.type_instance }

  let(:character) { Rip::Core::Character.new('r') }

  include_examples 'debug methods' do
    let(:class_to_s) { '#< System.Character >' }

    let(:instance) { character }
    let(:instance_to_s) { '#< #< System.Character > [ class, lowercase, to_string, uppercase ] data = `r >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['class']).to eq(Rip::Core::Class.type_instance) }
  end

  describe '@.class' do
    specify { expect(character['class']).to be(type_instance) }
  end

  describe '@.uppercase' do
    let(:character) { Rip::Core::Character.new('t') }

    specify { expect(character['uppercase']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:uppercase_character) { character['uppercase'].call([]) }

      specify { expect(uppercase_character).to eq(Rip::Core::Character.new('T')) }
    end
  end

  describe '@.lowercase' do
    let(:character) { Rip::Core::Character.new('G') }

    specify { expect(character['lowercase']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:lowercase_character) { character['lowercase'].call([]) }

      specify { expect(lowercase_character).to eq(Rip::Core::Character.new('g')) }
    end
  end

  describe '@.to_string' do
    specify { expect(character['to_string'].call([])).to eq(Rip::Core::String.from_native('`r')) }
  end
end
