require 'spec_helper'

describe Rip::Core::List do
  let(:class_instance) { Rip::Core::List.class_instance }

  let(:objects) { [] }
  let(:list) { Rip::Core::List.new(objects) }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.List' }
    let(:class_inspect) { '#< System.List >' }

    let(:instance) { list }
    let(:instance_to_s) { '[]' }
    let(:instance_inspect) { '#< System.List [ class ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(list['class']).to be(class_instance) }
  end
end
