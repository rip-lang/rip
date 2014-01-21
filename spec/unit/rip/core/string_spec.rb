require 'spec_helper'

describe Rip::Core::String do
  let(:class_instance) { Rip::Core::String.class_instance }

  let(:characters) { [] }
  let(:string) { Rip::Core::String.new(characters) }

  include_examples 'debug methods' do
    let(:class_to_s) { 'System.String' }
    let(:class_inspect) { '#< System.String >' }

    let(:instance) { string }
    let(:instance_to_s) { '""' }
    let(:instance_inspect) { '#< System.String [ class ] >' }
  end

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(string['class']).to be(class_instance) }
  end
end
