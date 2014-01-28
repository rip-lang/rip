require 'spec_helper'

describe Rip::Core::String do
  let(:context) { Rip::Utilities::Scope.new }

  let(:class_instance) { Rip::Core::String.class_instance }

  let(:characters) { [] }
  let(:string) { Rip::Core::String.new(characters) }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.String' }
    let(:class_inspect) { '#< System.String >' }

    let(:instance) { string }
    let(:instance_to_s) { '""' }
    let(:instance_inspect) { '#< System.String [ class, lowercase, uppercase ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
    specify { expect(class_instance.ancestors).to include(Rip::Core::List.class_instance) }
  end

  describe '@.class' do
    specify { expect(string['class']).to be(class_instance) }
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
end
