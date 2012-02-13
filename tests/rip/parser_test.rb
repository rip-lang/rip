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
end
