require 'spec_helper'

describe Rip::Core::Map do
  let(:type_instance) { Rip::Core::Map.type_instance }

  let(:pairs) { [] }
  let(:map) { Rip::Core::Map.new(pairs) }

  include_examples 'debug methods' do
    let(:type_to_s) { '#< System.Map >' }

    let(:instance) { map }
    let(:instance_to_s) { '#< #< System.Map > [ type ] pairs = {  } >' }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
  end

  describe '@.type' do
    specify { expect(map['type']).to be(type_instance) }
  end
end
