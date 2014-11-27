require 'spec_helper'

describe Rip::Core::Type do
  let(:ancestors) { [] }
  let(:type) { Rip::Core::Type.new(ancestors) }
  let(:type_instance) { Rip::Core::Type.type_instance }

  include_examples 'debug methods' do
    let(:type_to_s) { '#< System.Type >' }

    let(:instance) { type }
    let(:instance_to_s) { '#< #< System.Type > [ @, class, self ] >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['class']).to be(Rip::Core::Type.type_instance) }
  end

  describe '#ancestors' do
    context 'no explicit ancestors' do
      specify { expect(type.ancestors.count).to eq(2) }
      specify { expect(type.ancestors.first).to eq(type) }
      specify { expect(type.ancestors.last).to eq(Rip::Core::Object.type_instance) }
    end

    context 'explicit ancestors' do
      let(:ancestors) do
        [ Rip::Core::List.type_instance ]
      end

      specify { expect(type.ancestors).to eq(type.ancestors.uniq) }

      specify { expect(type.ancestors.count).to eq(3) }
      specify { expect(type.ancestors[0]).to eq(type) }
      specify { expect(type.ancestors[1]).to eq(Rip::Core::List.type_instance) }
      specify { expect(type.ancestors[2]).to eq(Rip::Core::Object.type_instance) }
    end
  end

  describe '@.@' do
    specify { expect(type['@']).to eq(Rip::Core::Prototype.new) }
  end

  describe '@.class' do
    specify { expect(type['class']).to eq(type_instance) }
  end

  describe '@.self' do
    specify { expect(type['self']).to eq(type) }
  end
end
