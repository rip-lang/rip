require 'spec_helper'

describe Rip do
  describe '.project_path' do
    specify { expect(Rip.project_path).to eq(Pathname.new(Dir.pwd).expand_path) }
  end

  describe '.project_path=' do
    around(:each) do |it_block|
      default_path = Rip.project_path
      Rip.project_path = 'some/other/directory'
      it_block.call
      Rip.project_path = default_path
    end

    specify { expect(Rip.project_path).to eq(Pathname.new('some/other/directory').expand_path) }
  end

  describe '.root' do
    specify { expect(Rip.root).to eq(Pathname.new('source').expand_path) }
  end
end
