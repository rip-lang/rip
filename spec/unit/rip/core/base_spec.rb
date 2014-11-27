require 'spec_helper'

describe Rip::Core::Base do
  let(:klass) do
    Class.new(Rip::Core::Base) do
      def initialize
        super
        self['class'] = self.class.type_instance
      end

      define_type_instance do |type_instance|
        type_instance['@']['instance_bar'] = :hello

        type_instance['type_bar'] = :goodbye
      end
    end
  end

  let(:type_instance) { klass.type_instance }
  let(:instance) { klass.new }

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['class']).to eq(Rip::Core::Class.type_instance) }
    specify { expect(type_instance['@']).to be_a(Rip::Core::Prototype) }
  end

  describe '[@][class]' do
    specify { expect(instance['class']).to be(type_instance) }
  end

  describe 'property lookup' do
    context 'on classes' do
      specify { expect(type_instance['type_bar']).to eq(:goodbye) }
    end

    context 'on instances' do
      describe 'instance-specific property' do
        let(:instance) do
          klass.new.tap do |reply|
            reply['foo'] = 42
          end
        end

        specify { expect(instance['foo']).to eq(42) }
      end

      describe 'prototype property' do
        specify { expect(instance['instance_bar']).to eq(:hello) }
      end
    end

    describe 'with invalid property' do
      specify do
        expect { instance['not-real'] }.to raise_error(Rip::Exceptions::RuntimeException)
      end

      it 'describes the problem when invalid reference' do
        actual = begin
          instance['not-real']
        rescue => e
          e.message
        end

        expect(actual).to eq('Unknown property `not-real`')
      end
    end
  end
end
