require 'spec_helper'

describe Rip::Core::Class do
  let(:ancestors) { [] }
  let(:klass) { Rip::Core::Class.new(ancestors) }
  let(:type_instance) { Rip::Core::Class.type_instance }

  include_examples 'debug methods' do
    let(:class_to_s) { '#< System.Class >' }

    let(:instance) { klass }
    let(:instance_to_s) { '#< #< System.Class > [ @, class, self ] >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['class']).to be(Rip::Core::Class.type_instance) }
  end

  describe '#ancestors' do
    context 'no explicit ancestors' do
      specify { expect(klass.ancestors.count).to eq(2) }
      specify { expect(klass.ancestors.first).to eq(klass) }
      specify { expect(klass.ancestors.last).to eq(Rip::Core::Object.type_instance) }
    end

    context 'explicit ancestors' do
      let(:ancestors) do
        [ Rip::Core::List.type_instance ]
      end

      specify { expect(klass.ancestors).to eq(klass.ancestors.uniq) }

      specify { expect(klass.ancestors.count).to eq(3) }
      specify { expect(klass.ancestors[0]).to eq(klass) }
      specify { expect(klass.ancestors[1]).to eq(Rip::Core::List.type_instance) }
      specify { expect(klass.ancestors[2]).to eq(Rip::Core::Object.type_instance) }
    end
  end

  describe '@.@' do
    specify { expect(klass['@']).to eq(Rip::Core::Prototype.new) }
  end

  describe '@.class' do
    specify { expect(klass['class']).to eq(type_instance) }
  end

  describe '@.self' do
    specify { expect(klass['self']).to eq(klass) }
  end
end
