require 'spec_helper'

describe Rip::Loaders::FileSystem do
  let(:root_directory) { Rip.root.parent + 'spec' + 'fixtures' + 'file_system' }

  let(:load_paths) { [ root_directory ] }
  let(:module_name) { './answer' }

  let(:loader) { Rip::Loaders::FileSystem.new(module_name, load_paths) }

  describe '#module_name' do
    specify { expect(loader.module_name).to eq(module_name) }
  end

  describe '#load_paths' do
    specify { expect(loader.load_paths.count).to eq(1) }
    specify { expect(loader.load_paths).to include(root_directory) }
  end

  describe '#load' do
    context 'module found' do
      specify { expect(loader.load).to eq(Rip::Core::Rational.integer(42)) }
    end

    context 'module not found' do
      let(:module_name) { './question' }
      specify { expect(loader.load).to be_nil }
    end
  end

  describe '#qualified_module_name' do
    let(:expanded_module_name) { (root_directory + "#{module_name}.rip").expand_path }

    specify { expect(loader.qualified_module_name).to eq(expanded_module_name) }
  end
end
