require 'spec_helper'

describe Rip::Core::Prototype do
  describe '#to_s' do
    context 'instance-level' do
      specify do
        prototype = Rip::Core::Prototype.new.tap do |prototype|
          prototype['language'] = :rip
        end
        expect(prototype.to_s).to eq('#< @ [ language ] >')
        expect(Rip::Core::Prototype.new.to_s).to eq('#< @ [ ] >')
      end
    end
  end
end
