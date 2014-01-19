require 'spec_helper'

describe Rip::Core::Class do
  let(:klass) { Rip::Core::Class.new }
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
