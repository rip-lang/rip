require 'spec_helper'

describe Rip::Compiler::Transform, :blur do
  describe 'some basics' do
    let(:empty) { ast('').first }
    let(:comment) { ast('# this is a comment').first }

    it 'transforms an empty file' do
      expect(empty).to eq(Rip::Nodes::Nil)
    end

    it 'transforms comments' do
      expect(comment).to eq(Rip::Nodes::Comment.new(' this is a comment'))
    end
  end

  describe 'atomic literals' do
    let(:integer) { ast('42').first }
    let(:decimal) { ast('4.2').first }
    let(:negative) { ast('-3').first }
    let(:long) { ast('123_456_789').first }
    let(:character) { ast('`f').first }
    let(:symbol_string) { ast(':one').first }
    let(:single_string) { ast('\'two\'').first }
    let(:double_string) { ast('"three"').first }

    let(:here_doc) do
      rip_doc = <<-RIP_DOC
<<HERE_DOC
here docs are good for multi-line strings
HERE_DOC
      RIP_DOC
      ast(rip_doc).first
    end

    let(:regex) { ast('/hello/').first }

    it 'transforms numbers' do
      expect(integer).to eq(Rip::Nodes::Integer.new('42'))
      expect(decimal).to eq(Rip::Nodes::Decimal.new('4.2'))
      expect(negative).to eq(Rip::Nodes::Integer.new('3', '-'))
      expect(long).to eq(Rip::Nodes::Integer.new('123_456_789'))
    end

    it 'transforms characters' do
      expect(character).to eq(Rip::Nodes::Character.new('f'))
    end

    it 'transforms strings' do
      expect(symbol_string).to eq(Rip::Nodes::String.new('one'))
      expect(single_string).to eq(Rip::Nodes::String.new('two'))
      expect(double_string).to eq(Rip::Nodes::String.new('three'))
      expect(here_doc).to eq(Rip::Nodes::String.new("here docs are good for multi-line strings\n"))
    end

    it 'transforms regular expressions' do
      expect(regex).to eq(Rip::Nodes::RegularExpression.new('hello'))
    end
  end
end
