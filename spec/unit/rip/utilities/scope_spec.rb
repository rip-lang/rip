require 'spec_helper'

describe Rip::Utilities::Scope do
  subject { scope_foo }
  let(:scope_foo) { Rip::Utilities::Scope.new(:foo => 111) }

  its(:context) { should eq(:foo => 111) }

  context 'extending' do
    subject { scope_bar }
    let(:scope_bar) { scope_foo.set(:bar, 222) }

    its(:context) { should eq(:foo => 111, :bar => 222) }
    specify { expect(scope_foo.context).to eq(:foo => 111) }

    context 'shadowing' do
      subject { scope_baz }
      let(:scope_baz) { scope_bar.set(:bar, 333) }

      its(:context) { should eq(:foo => 111, :bar => 333) }
      specify { expect(scope_bar.context).to eq(:foo => 111, :bar => 222) }
      specify { expect(scope_foo.context).to eq(:foo => 111) }
    end
  end
end
