require 'spec_helper'

describe Rip::Core::Boolean do
  let(:rip_true) { Rip::Core::Boolean.true }
  let(:rip_false) { Rip::Core::Boolean.false }

  describe '.true' do
    specify { expect(rip_true).to eq(Rip::Core::Boolean.true) }
    specify { expect(rip_true).to_not eq(Rip::Core::Boolean.false) }
  end

  describe '.false' do
    specify { expect(rip_false).to eq(Rip::Core::Boolean.false) }
    specify { expect(rip_false).to_not eq(Rip::Core::Boolean.true) }
  end
end
