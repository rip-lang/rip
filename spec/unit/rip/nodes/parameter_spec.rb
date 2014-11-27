require 'spec_helper'

describe Rip::Nodes::Parameter do
  let(:location) { location_for }

  let(:name) { 'arg' }
  let(:type) { nil }
  let(:parameter) { Rip::Nodes::Parameter.new(location, name, type) }

  let(:context) { Rip::Compiler::Driver.global_context.nested_context }

  describe '#interpret' do
    let(:core_parameter) { parameter.interpret(context) }

    specify do
      expect(core_parameter).to be_a(Rip::Core::Parameter)
    end

    context 'without type restriction' do
      it 'allows any type' do
        expect(core_parameter.type).to eq(Rip::Core::Object.type_instance)
      end
    end

    context 'with type restriction' do
      let(:type) do
        Rip::Nodes::Property.new(location, Rip::Nodes::Reference.new(location, 'System'), 'Integer')
      end

      it 'only allows integers' do
        expect(core_parameter.type).to eq(Rip::Core::Integer.type_instance)
      end
    end
  end
end
