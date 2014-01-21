require 'spec_helper'

describe Rip::Core::Map do
  let(:class_instance) { Rip::Core::Map.class_instance }

  let(:pairs) { [] }
  let(:map) { Rip::Core::Map.new(pairs) }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.Map' }
    let(:class_inspect) { '#< System.Map >' }

    let(:instance) { map }
    let(:instance_to_s) { '{}' }
    let(:instance_inspect) { '#< System.Map [ class ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(map['class']).to be(class_instance) }
  end
end
