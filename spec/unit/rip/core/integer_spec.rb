require 'spec_helper'

describe Rip::Core::Integer do
  let(:forty_two) { Rip::Core::Integer.new(42) }
  let(:class_instance) { Rip::Core::Integer.class_instance }

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
  end

  describe '@.class' do
    specify { expect(forty_two['class']).to be(class_instance) }
  end
end
