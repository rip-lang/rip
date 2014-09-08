require 'spec_helper'

describe Rip::Nodes::Parameter do
  let(:location) { location_for }

  let(:name) { 'arg' }
  let(:parameter) { Rip::Nodes::Parameter.new(location, name) }

  let(:context) { Rip::Compiler::Driver.global_context.nested_context }

  let(:forty_two) { Rip::Core::Integer.new(42) }

  describe '#bind' do
    before(:each) { parameter.bind(context, forty_two) }

    specify { expect(context.symbols).to include(name) }
    specify { expect(context[name]).to eq(forty_two) }
  end
end
