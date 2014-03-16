require 'spec_helper'

describe Rip::Nodes::Parameter do
  let(:location) { location_for }

  let(:name) { 'arg' }
  let(:type) { }
  let(:default) { }
  let(:parameter) { Rip::Nodes::Parameter.new(location, name, type, default) }

  let(:context) { Rip::Compiler::Driver.global_context }

  let(:system_class_node) { Rip::Nodes::Reference.new(location, 'System') }
  let(:integer_class_node) { Rip::Nodes::Property.new(location, system_class_node, 'Integer') }
  let(:character_class_node) { Rip::Nodes::Property.new(location, system_class_node, 'Character') }

  let(:three_node) { Rip::Nodes::Integer.new(location, 3) }
  let(:seven_node) { Rip::Nodes::Integer.new(location, 7) }

  let(:three) { Rip::Core::Integer.new(3) }
  let(:seven) { Rip::Core::Integer.new(7) }
  let(:forty_two) { Rip::Core::Integer.new(42) }

  describe '#bind' do
    context 'no type, no default' do
      specify do
        expect(parameter.bind(context, nil)).to be_nil
        expect(parameter.bind(context, forty_two)).to eq(Rip::Nodes::BoundParameter.new(name, forty_two))
      end
    end

    context 'no type, yes default' do
      let(:default) { three_node }

      specify do
        expect(parameter.bind(context, nil)).to eq(Rip::Nodes::BoundParameter.new(name, three))
        expect(parameter.bind(context, forty_two)).to eq(Rip::Nodes::BoundParameter.new(name, forty_two))
      end
    end

    context 'yes type, no default' do
      let(:type) { integer_class_node }

      specify do
        expect(parameter.bind(context, nil)).to be_nil
        expect(parameter.bind(context, forty_two)).to eq(Rip::Nodes::BoundParameter.new(name, forty_two))
      end
    end

    context 'yes type, yes default' do
      let(:type) { integer_class_node }
      let(:default) { seven_node }

      specify do
        expect(parameter.bind(context, nil)).to eq(Rip::Nodes::BoundParameter.new(name, seven))
        expect(parameter.bind(context, forty_two)).to eq(Rip::Nodes::BoundParameter.new(name, forty_two))
      end
    end

    context 'yes type, no default, type mis-match' do
      let(:type) { character_class_node }

      specify do
        expect(parameter.bind(context, nil)).to be_nil
        expect { parameter.bind(context, forty_two) }.to raise_exception(Rip::Exceptions::CompilerException)
      end
    end

    context 'yes type, yes default, type mis-match' do
      let(:type) { character_class_node }
      let(:default) { seven_node }

      specify do
        expect { parameter.bind(context, nil) }.to raise_exception(Rip::Exceptions::CompilerException)
        expect { parameter.bind(context, forty_two) }.to raise_exception(Rip::Exceptions::CompilerException)
      end
    end
  end
end
