require 'spec_helper'

describe Rip::Compiler::AST do
  let(:location) { location_for }

  context 'some basics' do
    describe 'tree for empty module' do
      let(:rip) { '' }
      let(:rip_module) { Rip::Nodes::Module.new(location, []) }

      specify do
        expect(syntax_tree(rip)).to eq(rip_module)
        expect(syntax_tree(rip).expressions.count).to eq(0)
      end
    end

    describe 'tree for comments' do
      let(:rip) { '# this is a comment' }
      let(:comment) { Rip::Nodes::Comment.new(location.add_character, ' this is a comment') }
      let(:rip_module) { Rip::Nodes::Module.new(location, [ comment ]) }

      let(:actual_comment) { syntax_tree(rip).expressions.first }

      specify do
        expect(syntax_tree(rip).expressions.count).to eq(1)
        expect(actual_comment).to eq(comment)
      end
    end
  end
end
