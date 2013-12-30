require 'spec_helper'

describe Rip::Core::Class do
  let(:klass) { Rip::Core::Class.new }
  let(:class_instance) { Rip::Core::Class.class_instance }

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to be(Rip::Core::Class.class_instance) }
  end

  describe '@.@' do
    specify { expect(klass['@']).to eq(Rip::Core::Prototype.new) }
  end
end
