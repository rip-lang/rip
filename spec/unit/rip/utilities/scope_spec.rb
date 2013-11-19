require 'spec_helper'

describe Rip::Utilities::Scope do
  subject { scope_foo }
  let(:scope_foo) { Rip::Utilities::Scope.new(:foo => 111) }

  its(:context) { should eq(:foo => 111) }

  context 'extending' do
    before(:each) { scope_foo[:bar] = 222 }

    its(:context) { should eq(:foo => 111, :bar => 222) }

    context 'shadowing' do
      subject { scope_bar }
      let(:scope_bar) { scope_foo.nested_context(:bar => 333) }

      its(:context) { should eq(:foo => 111, :bar => 333) }
      specify { expect(scope_foo.context).to eq(:foo => 111, :bar => 222) }
    end

    context 'misses' do
      subject { nested_foo }
      let(:nested_foo) { scope_foo.nested_context }

      it 'returns nil when nothing is present' do
        expect(nested_foo[:zebra]).to be_nil
      end
    end
  end
end
