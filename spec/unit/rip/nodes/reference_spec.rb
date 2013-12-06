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

  describe '#interpret' do
    it 'looks up the value for reference' do
      expect(reference_node.interpret('rip' => 4)).to eq(4)
      expect(reference_node.interpret('rip' => -3)).to eq(-3)
    end

    it 'raises an exception for invalid reference' do
      expect { reference_node.interpret('not-rip' => 4) }.to raise_error(Rip::Exceptions::RuntimeException)
    end

    it 'describes the problem when invalid reference' do
      actual = begin
        reference_node.interpret('not-rip' => 4)
      rescue => e
        e.message
      end

      expect(actual).to eq('Unknown reference `rip`')
    end
  end
end
