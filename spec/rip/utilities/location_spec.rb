require 'spec_helper'

describe Rip::Utilities::Location do
  subject { location }
  let(:location) { Rip::Utilities::Location.new(:rspec, 0, 1, 0) }

  describe '#==' do
    it 'glosses over superficial differences' do
      expect(location).to eq(Rip::Utilities::Location.new(:rspec, 0, 1, 0))
    end

    it 'notices important difference in source' do
      expect(location).not_to eq(location_for(:origin => :cucumber))
    end

    it 'notices important differences in position' do
      expect(location).not_to eq(location_for(:absolute_position => 3))
    end
  end

  describe '#to_s' do
    its(:to_s) { should eq('rspec:1:0(0)') }

    context 'in another file' do
      let(:location) { Rip::Utilities::Location.new('lib/rip.rip', 47, 8, 3) }

      its(:to_s) { should eq('lib/rip.rip:8:3(47)') }
    end
  end

  describe '#add_character' do
    let(:new_location) { Rip::Utilities::Location.new(:rspec, 5, 1, 5) }

    it 'returns a new location offset by specified characters' do
      expect(location.add_character(5)).to eq(new_location)
    end
  end

  describe '#add_line' do
    let(:new_location) { Rip::Utilities::Location.new(:rspec, 2, 3, 2) }

    it 'returns a new location offset by specified lines' do
      expect(location.add_line(2)).to eq(new_location)
    end
  end
end
