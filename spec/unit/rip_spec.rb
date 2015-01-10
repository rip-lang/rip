require 'spec_helper'

describe Rip do
  describe '.root' do
    specify { expect(Rip.root).to eq(Pathname.new('source').expand_path) }
  end
end
