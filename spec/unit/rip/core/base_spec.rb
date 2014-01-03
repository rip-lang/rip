require 'spec_helper'

describe Rip::Core::Base do
  let(:klass) do
    Class.new(Rip::Core::Base) do
      def initialize
        super
        self['class'] = self.class.class_instance
      end

      def self.class_instance
        return @class_instance if instance_variable_defined? :@class_instance

        @class_instance = Rip::Core::Class.new.tap do |reply|
          reply['class'] = Rip::Core::Class.class_instance

          reply['@']['bar'] = :hello
        end
      end
    end
  end

  let(:class_instance) { klass.class_instance }
  let(:prototype) { class_instance['@'] }
  let(:instance) { klass.new }

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
    specify { expect(class_instance['@']).to be_a(Rip::Core::Prototype) }
  end

  describe '[@][class]' do
    specify { expect(instance['class']).to be(class_instance) }
  end

  describe 'property lookup' do
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
        specify { expect(instance['bar']).to eq(:hello) }
      end

      describe 'invalid property' do
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

  describe '#to_s' do
    context 'class-level' do
      specify do
        expect(Rip::Core::Character.class_instance.to_s).to eq('System.Character')
        expect(Rip::Core::Integer.class_instance.to_s).to eq('System.Integer')
      end
    end

    context 'instance-level' do
      specify do
        expect(Rip::Core::Character.new('c').to_s).to eq('`c')
        expect(Rip::Core::Integer.new(42).to_s).to eq('42')
      end
    end
  end

  describe '#inspect' do
    context 'class-level' do
      specify do
        expect(Rip::Core::Character.class_instance.inspect).to eq('#< System.Character >')
        expect(Rip::Core::Integer.class_instance.inspect).to eq('#< System.Integer >')
      end
    end

    context 'instance-level' do
      specify do
        expect(Rip::Core::Character.new('c').inspect).to eq('#< System.Character [ class ] data = `c >')
        expect(Rip::Core::Integer.new(42).inspect).to eq('#< System.Integer [ %, *, +, -, /, class ] data = 42 >')
      end
    end
  end
end
