require 'spec_helper'

describe Rip::Core::Lambda do
  let(:class_instance) { Rip::Core::Lambda.class_instance }

  let(:location) { location_for }
  let(:context) { Rip::Utilities::Scope.new }

  let(:keyword) { Rip::Utilities::Keywords[:dash_rocket] }
  let(:parameters) { [] }
  let(:body_expressions) { [] }
  let(:body) { Rip::Nodes::BlockBody.new(location, body_expressions) }

  let(:rip_lambda) { Rip::Core::Lambda.new(context, keyword, parameters, body) }

  describe '.class_instance' do
    specify { expect(class_instance).to_not be_nil }
    specify { expect(class_instance['class']).to eq(Rip::Core::Class.class_instance) }
  end

  describe '@.class' do
    specify { expect(rip_lambda['class']).to be(class_instance) }
  end
end
