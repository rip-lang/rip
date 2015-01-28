require 'spec_helper'

describe Rip::Core::String do
  let(:context) { Rip::Compiler::Scope.new }

  let(:type_instance) { Rip::Core::String.type_instance }

  let(:characters) { [] }
  let(:string) { Rip::Core::String.new(characters) }

  include_examples 'debug methods' do
    let(:type_to_s) { '#< System.String >' }

    let(:instance) { string }
    let(:instance_to_s) { '#< #< System.String > [ lowercase, strip, to_string, type, uppercase ] characters = "" >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
  end

  describe '.from_native' do
    let(:actual) { Rip::Core::String.from_native(string) }
    let(:expected) { Rip::Core::String.new(rip_string_nodes(location_for, string)) }

    context 'empty string' do
      let(:string) { '' }
      specify { expect(actual).to eq(expected) }
    end

    context 'non-empty string' do
      let(:string) { 'foo' }
      specify { expect(actual).to eq(expected) }
    end
  end

  describe '@.type' do
    specify { expect(string['type']).to be(type_instance) }
  end

  describe '@.+' do
    let(:characters) do
      [
        Rip::Core::Character.new('c'),
        Rip::Core::Character.new('a'),
        Rip::Core::Character.new('t')
      ]
    end

    specify { expect(string['+']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:actual) do
        dog = Rip::Core::String.new([
          Rip::Core::Character.new('D'),
          Rip::Core::Character.new('O'),
          Rip::Core::Character.new('G')
        ])

        string['+'].call(context, [ dog ])
      end

      let(:expected) { Rip::Core::String.from_native('catDOG') }

      specify { expect(actual).to eq(expected) }
    end
  end

  describe '@.uppercase' do
    let(:characters) do
      [
        Rip::Core::Character.new('c'),
        Rip::Core::Character.new('a'),
        Rip::Core::Character.new('t')
      ]
    end

    specify { expect(string['uppercase']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:uppercase_characters) do
        [
          Rip::Core::Character.new('C'),
          Rip::Core::Character.new('A'),
          Rip::Core::Character.new('T')
        ]
      end

      let(:uppercase_string) { string['uppercase'].call(context, []) }

      specify { expect(uppercase_string).to eq(Rip::Core::String.new(uppercase_characters)) }
    end
  end

  describe '@.lowercase' do
    let(:characters) do
      [
        Rip::Core::Character.new('D'),
        Rip::Core::Character.new('o'),
        Rip::Core::Character.new('G')
      ]
    end

    specify { expect(string['lowercase']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:lowercase_characters) do
        [
          Rip::Core::Character.new('d'),
          Rip::Core::Character.new('o'),
          Rip::Core::Character.new('g')
        ]
      end

      let(:lowercase_string) { string['lowercase'].call(context, []) }

      specify { expect(lowercase_string).to eq(Rip::Core::String.new(lowercase_characters)) }
    end
  end

  describe '@.reverse' do
    let(:characters) do
      [
        Rip::Core::Character.new('r'),
        Rip::Core::Character.new('i'),
        Rip::Core::Character.new('p')
      ]
    end

    specify { expect(string['reverse']).to be_a(Rip::Core::Lambda) }

    context 'invocation' do
      let(:reverse_characters) do
        [
          Rip::Core::Character.new('p'),
          Rip::Core::Character.new('i'),
          Rip::Core::Character.new('r')
        ]
      end

      let(:reverse_string) { string['reverse'].call(context, []) }

      specify { expect(reverse_string).to eq(Rip::Core::String.new(reverse_characters)) }
    end
  end

  describe '@.to_string' do
    context 'empty string' do
      specify { expect(string['to_string'].call(context, [])).to eq(string) }
    end

    context 'non-empty string' do
      let(:characters) do
        [
          Rip::Core::Character.new('f'),
          Rip::Core::Character.new('o'),
          Rip::Core::Character.new('o')
        ]
      end

      specify { expect(string['to_string'].call(context, [])).to eq(string) }
    end
  end
end
