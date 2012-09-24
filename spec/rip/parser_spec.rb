# encoding: utf-8

require 'spec_helper'

describe Rip::Parser do
  context 'some basics' do
    let(:empty) { parser.parse_file(samples_path + 'empty.rip') }
    let(:comment) { parser.comment.parse('# this is a comment') }

    it 'parses an empty file' do
      expect(empty).to eq('')
    end

    it 'parses comments' do
      expect(comment[:comment]).to eq(' this is a comment')
    end

    it 'recognizes various whitespace sequences' do
      {
        [' ', "\t", "\r", "\n", "\r\n"] => :whitespace,
        [' ', "\t\t"]                   => :whitespaces,
        ['', "\n", "\t\r"]              => :whitespaces?,
        [' ', "\t"]                     => :space,
        [' ', "\t\t", "  \t  \t  "]     => :spaces,
        ['', ' ', "  \t  \t  "]         => :spaces?,
        ["\n", "\r", "\r\n"]            => :eol,
        ['', "\n", "\r\r"]              => :eols
      }.each do |whitespaces, method|
        space_parser = parser.send(method)
        whitespaces.each do |space|
          expect(space_parser.parse(space)).to eq(space)
        end
      end
    end
  end

  context 'utilities' do
    describe '#surround_with' do
      let(:surrounded) { parser.surround_with('(', parser.object.as(:object), ')').parse('(:one)') }

      let(:rip_list) do
        <<-RIP_LIST
[
  :one
]
        RIP_LIST
      end
      let(:list) { parser.surround_with('[', parser.object.as(:list), ']').parse(rip_list.strip) }

      let(:rip_block) do
        <<-RIP_LIST
{
  # comment
}
        RIP_LIST
      end
      let(:block) { parser.surround_with('{', parser.statement.as(:body), '}').parse(rip_block.strip) }

      it 'surrounds arbitrary tokens' do
        expect(surrounded[:object][:string]).to eq('one')
        expect(list[:list][:string]).to eq('one')
        expect(block[:body][:comment]).to eq(' comment')
      end
    end

    describe '#thing_list' do
      let(:empty) { parser.thing_list(parser.object, parser.whitespaces?).as(:list).parse('') }
      let(:single) { parser.thing_list(parser.object).as(:label).parse(':single') }
      let(:double_list) { parser.thing_list(parser.object).as(:label).parse(':one, :two') }
      let(:full) { parser.thing_list(parser.integer, '**').as(:numbers).parse('1 ** 2 ** 3') }

      it 'parses an arbitrary list of tokens' do
        expect(empty[:list]).to eq([])
        expect(single[:label].first[:string]).to eq('single')

        expect(double_list[:label].first[:string]).to eq('one')
        expect(double_list[:label].last[:string]).to eq('two')

        expect(full[:numbers][0][:integer]).to eq('1')
        expect(full[:numbers][1][:integer]).to eq('2')
        expect(full[:numbers][2][:integer]).to eq('3')
      end
    end
  end

  describe '#reference' do
    it 'recognizes valid references' do
      [
        'name',
        'Person',
        '==',
        'save!',
        'valid?',
        'long_ref-name',
        '*/-+<>&$~%',
        'one_9',
        'É¹ÇÊ‡É¹oÔ€uÉlâˆ€â„¢'
      ].each do |reference|
        expect(parser.reference.parse(reference)[:reference]).to eq(reference)
      end
    end

    it 'skips invalid references' do
      [
        'one.two',
        '999',
        '6teen',
        'rip rocks',
        'key:value'
      ].each do |reference|
        expect do
          parser.reference.parse(reference)
        end.to raise_error(Parslet::ParseFailed) # Rip::ParseError
      end
    end

    it 'recognizes special references' do
      expect(parser.reference.parse('nilly')[:reference].to_s).to eql('nilly')
      expect(parser.reference.parse('nil')[:reference][:nil].to_s).to eql('nil')
      expect(parser.reference.parse('true')[:reference][:true].to_s).to eql('true')
      expect(parser.reference.parse('false')[:reference][:false].to_s).to eql('false')
      expect(parser.reference.parse('Kernel')[:reference][:kernel].to_s).to eql('Kernel')
    end

    it 'assigns to a reference' do
      assignment = parser.assignment.parse('favorite_language = :rip')
      expect(assignment[:assignment][:reference]).to eq('favorite_language')
      expect(assignment[:assignment][:value][:string]).to eq('rip')
    end
  end

  describe '#block' do
    let(:empty_block) { parser.block.parse('{}') }
    let(:block) do
      rip_block = <<-RIP_LIST
{
  # comment
  :words
}
      RIP_LIST
      parser.block.parse(rip_block.strip)
    end

    it 'parses empty blocks' do
      expect(empty_block[:body]).to eq([])
    end

    it 'parses useful blocks' do
      expect(block[:body].count).to be(2)
      expect(block[:body].first[:comment]).to eq(' comment')
      expect(block[:body].last[:string]).to eq('words')
    end
  end
end
