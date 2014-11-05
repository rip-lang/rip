require 'spec_helper'

describe Rip::Core::Boolean do
  let(:context) { Rip::Compiler::Scope.new }

  let(:rip_true) { Rip::Core::Boolean.true }
  let(:rip_false) { Rip::Core::Boolean.false }

  include_examples 'debug methods' do
    let(:class_instance) { Rip::Core::Boolean.class_instance }
    let(:class_to_s) { '#< System.Boolean >' }

    let(:instance) { rip_false }
    let(:instance_to_s) { '#< #< System.Boolean > [ ==, class, to_boolean, to_string ] false >' }
  end

  describe '.true' do
    specify { expect(rip_true).to eq(Rip::Core::Boolean.true) }
    specify { expect(rip_true).to_not eq(Rip::Core::Boolean.false) }
  end

  describe '.false' do
    specify { expect(rip_false).to eq(Rip::Core::Boolean.false) }
    specify { expect(rip_false).to_not eq(Rip::Core::Boolean.true) }
  end

  describe '@.to_boolean' do
    specify { expect(rip_true['to_boolean'].call([])).to eq(rip_true) }
    specify { expect(rip_false['to_boolean'].call([])).to eq(rip_false) }
  end

  describe '@.to_string' do
    specify { expect(rip_true['to_string'].call([])).to eq(Rip::Core::String.from_native('true')) }
    specify { expect(rip_false['to_string'].call([])).to eq(Rip::Core::String.from_native('false')) }
  end
end
