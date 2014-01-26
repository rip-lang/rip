require 'spec_helper'

describe Rip::Compiler::Driver do
  subject { driver }
  let(:driver) { Rip::Compiler::Driver.new(ast) }

  let(:location) { location_for }

  describe '#global_context' do
    let(:ast) { nil }

    context 'provides globally assumed members' do
      specify { expect(driver.global_context.symbols).to match_array(['System', 'true', 'false']) }

      context 'System' do
        let(:expected) { Rip::Nodes::Reference.new(location, 'System').interpret(driver.global_context) }

        specify { expect(driver.global_context['System']).to eq(expected) }
      end

      context 'true' do
        let(:expected) { Rip::Nodes::Reference.new(location, 'true').interpret(driver.global_context) }

        specify { expect(driver.global_context['true']).to eq(expected) }
      end

      context 'false' do
        let(:expected) { Rip::Nodes::Reference.new(location, 'false').interpret(driver.global_context) }

        specify { expect(driver.global_context['false']).to eq(expected) }
      end
    end
  end
end
