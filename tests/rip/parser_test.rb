require_relative '../test_case'

class ParserTest < TestCase
  def test_parse_file_empty
    empty = parser.parse_file(samples_path + 'empty.rip')
    assert_equal '', empty
  end

  def test_comment
    comment = parser.comment.parse('# this is a comment')
    assert_equal ' this is a comment', comment[:comment]
  end

  def test_whitespace
    [' ', "\t", "\r", "\n", "\r\n"].each do |space|
      assert_equal space, parser.whitespace.parse(space)
    end
  end

  def test_whitespaces
    [' ', "\t\t"].each do |space|
      assert_equal space, parser.whitespaces.parse(space)
    end
  end

  def test_whitespaces?
    ['', "\n", "\t\r"].each do |space|
      assert_equal space, parser.whitespaces?.parse(space)
    end
  end

  def test_space
    [' ', "\t"].each do |space|
      assert_equal space, parser.space.parse(space)
    end
  end

  def test_spaces
    [' ', "\t\t", "  \t  \t  "].each do |space|
      assert_equal space, parser.spaces.parse(space)
    end
  end

  def test_spaces?
    ['', ' ', "  \t  \t  "].each do |space|
      assert_equal space, parser.spaces?.parse(space)
    end
  end

  def test_eol
    ["\n", "\r", "\r\n"].each do |space|
      assert_equal space, parser.eol.parse(space)
    end
  end

  def test_eols
    ['', "\n", "\r\r"].each do |space|
      assert_equal space, parser.eols.parse(space)
    end
  end

  def test_surround_with
    surrounded = parser.surround_with('(', parser.object.as(:object), ')').parse('(:one)')
    assert_equal 'one', surrounded[:object][:string]

    rip_list = <<-RIP_LIST
[
  :one
]
    RIP_LIST
    list = parser.surround_with('[', parser.object.as(:list), ']').parse(rip_list.strip)
    assert_equal 'one', list[:list][:string]

    rip_block = <<-RIP_LIST
{
  # comment
}
    RIP_LIST
    block = parser.surround_with('{', parser.statement.as(:body), '}').parse(rip_block.strip)
    assert_equal ' comment', block[:body][:comment]
  end

  def test_thing_list
    empty = parser.thing_list(parser.object, parser.whitespaces?).as(:list).parse('')
    assert_equal [], empty[:list]

    single = parser.thing_list(parser.object, ',').as(:label).parse(':single')
    assert_equal 'single', single[:label].first[:string]

    full = parser.thing_list(parser.integer, '**').as(:numbers).parse('1 ** 2 ** 3')
    assert_equal '1', full[:numbers][0][:integer]
    assert_equal '2', full[:numbers][1][:integer]
    assert_equal '3', full[:numbers][2][:integer]
  end
end
