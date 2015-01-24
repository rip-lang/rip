require 'spec_helper'

describe Rip::Core::System do
  let(:type_instance) { Rip::Core::System.type_instance }

  describe 'debug methods' do
    specify { expect(type_instance.to_s).to eq('#< System >') }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
    specify { expect(type_instance.symbols).to match_array(['@', 'Boolean', 'Character', 'IO', 'Lambda', 'List', 'Object', 'Rational', 'String', 'type', 'self', 'to_string']) }
  end
end
