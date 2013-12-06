require 'spec_helper'

describe Rip::Utilities::Scope do
  subject { scope_foo }
  let(:scope_foo) { Rip::Utilities::Scope.new }

  before(:each) { scope_foo[:foo] = 111 }

  specify { expect(scope_foo[:foo]).to be(111) }
  specify { expect(scope_foo[:zebra]).to be_nil }

  context 'extending' do
    before(:each) { scope_foo[:bar] = 222 }

    specify { expect(scope_foo[:foo]).to be(111) }
    specify { expect(scope_foo[:bar]).to be(222) }

    context 'shadowing' do
      subject { scope_bar }
      let(:scope_bar) { scope_foo.nested_context }

      before(:each) { scope_bar[:bar] = 333 }

      specify { expect(scope_foo[:foo]).to be(111) }
      specify { expect(scope_foo[:bar]).to be(222) }

      specify { expect(scope_bar[:foo]).to be(111) }
      specify { expect(scope_bar[:bar]).to be(333) }
    end
  end
end
