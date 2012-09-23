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
  end

  context 'whitespace' do
    describe '#whitespace' do
      it 'recognizes single whitespace sequences' do
        [' ', "\t", "\r", "\n", "\r\n"].each do |space|
          expect(parser.whitespace.parse(space)).to eq(space)
        end
      end
    end

    describe '#whitespaces' do
      it 'recognizes consecutive whitespace sequences' do
        [' ', "\t\t"].each do |space|
          expect(parser.whitespaces.parse(space)).to eq(space)
        end
      end
    end

    describe '#whitespaces?' do
      it 'recognizes any whitespace sequences' do
        ['', "\n", "\t\r"].each do |space|
          expect(parser.whitespaces?.parse(space)).to eq(space)
        end
      end
    end

    describe '#space' do
      it 'recognizes single space sequences' do
        [' ', "\t"].each do |space|
          expect(parser.space.parse(space)).to eq(space)
        end
      end
    end

    describe '#spaces' do
      it 'recognizes consecutive space sequences' do
        [' ', "\t\t", "  \t  \t  "].each do |space|
          expect(parser.spaces.parse(space)).to eq(space)
        end
      end
    end

    describe '#spaces?' do
      it 'recognizes any space sequences' do
        ['', ' ', "  \t  \t  "].each do |space|
          expect(parser.spaces?.parse(space)).to eq(space)
        end
      end
    end

    describe '#eol' do
      it 'recognizes single end of line sequences' do
        ["\n", "\r", "\r\n"].each do |space|
          expect(parser.eol.parse(space)).to eq(space)
        end
      end
    end

    describe '#eols' do
      it 'recognizes consecutive end of line sequences' do
        ['', "\n", "\r\r"].each do |space|
          expect(parser.eols.parse(space)).to eq(space)
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
end
