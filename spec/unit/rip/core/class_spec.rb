require 'spec_helper'

describe Rip::Core::Class do
  let(:ancestors) { [] }
  let(:klass) { Rip::Core::Class.new(ancestors) }
  let(:class_instance) { Rip::Core::Class.class_instance }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.Class' }
    let(:class_inspect) { '#< System.Class >' }

    let(:instance) { klass }
    let(:instance_to_s) { '#< System.Class [ @, class, self ] >' }
    let(:instance_inspect) { '#< System.Class [ @, class, self ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to be(Rip::Core::Class.class_instance) }
  end

  describe '#ancestors' do
    context 'no explicit ancestors' do
      specify { expect(klass.ancestors.count).to eq(2) }
      specify { expect(klass.ancestors.first).to eq(klass) }
      specify { expect(klass.ancestors.last).to eq(Rip::Core::Object.class_instance) }
    end

    context 'explicit ancestors' do
      let(:ancestors) do
        [ Rip::Core::List.class_instance ]
      end

      specify { expect(klass.ancestors).to eq(klass.ancestors.uniq) }

      specify { expect(klass.ancestors.count).to eq(3) }
      specify { expect(klass.ancestors[0]).to eq(klass) }
      specify { expect(klass.ancestors[1]).to eq(Rip::Core::List.class_instance) }
      specify { expect(klass.ancestors[2]).to eq(Rip::Core::Object.class_instance) }
    end
  end

  describe '@.@' do
    specify { expect(klass['@']).to eq(Rip::Core::Prototype.new) }
  end

  describe '@.class' do
    specify { expect(klass['class']).to eq(class_instance) }
  end

  describe '@.self' do
    specify { expect(klass['self']).to eq(klass) }
  end
end
