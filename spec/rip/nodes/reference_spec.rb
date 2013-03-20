require 'spec_helper'

describe Rip::Nodes::Reference do
  let(:location) { location_for }
  let(:rip) { 'rip' }
  let(:reference_node) { Rip::Nodes::Reference.new(location, rip) }

  describe '#==' do
    it 'glosses over superficial differences' do
      expect(reference_node).to eq(Rip::Nodes::Reference.new(location, 'rip'))
    end

    it 'notices important differences in location' do
      expect(reference_node).not_to eq(Rip::Nodes::Reference.new(location_for(:origin => :cucumber), 'rip'))
    end

    it 'notices important differences in node text' do
      expect(reference_node).not_to eq(Rip::Nodes::Reference.new(location, 'ruby'))
    end
  end
end
