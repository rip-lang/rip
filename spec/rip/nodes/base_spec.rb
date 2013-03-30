require 'spec_helper'

describe Rip::Nodes::Base do
  let(:location) { location_for }
  let(:base_node) { Rip::Nodes::Base.new(location) }

  describe '#==' do
    it 'glosses over superficial differences' do
      expect(base_node).to eq(Rip::Nodes::Base.new(location))
    end

    it 'notices important differences in location' do
      expect(base_node).not_to eq(Rip::Nodes::Base.new(location_for(:origin => :cucumber)))
    end
  end
end
