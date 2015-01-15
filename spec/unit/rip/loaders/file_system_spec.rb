require 'spec_helper'

describe Rip::Loaders::FileSystem do
  let(:load_path) { Rip.root.parent + 'spec' + 'fixtures' + 'file_system' }
  let(:module_name) { load_path + 'answer' }
  let(:loader) { Rip::Loaders::FileSystem.new(module_name) }

  describe '#module_name' do
    specify { expect(loader.module_name).to eq(module_name.sub_ext('.rip')) }
  end

  describe '#load_path' do
    specify { expect(loader.load_path).to eq(load_path) }
  end

  describe '#load' do
    context 'module found' do
      specify { expect(loader.load).to eq(Rip::Core::Rational.integer(42)) }
    end

    context 'module not found' do
      let(:module_name) { load_path + 'question' }
      specify { expect { loader.load }.to raise_error(Rip::Exceptions::LoadException) }
    end
  end
end
