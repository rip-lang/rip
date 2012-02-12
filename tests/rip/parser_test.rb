require_relative '../test_case'

class ParserTest < TestCase
  let(:empty_rip) { samples_path + 'empty.rip' }
  let(:comment_rip) { samples_path + 'comment.rip' }

  def test_parse_empty_file
    parse_tree = parser.parse_file(empty_rip)
    assert_equal '', parse_tree
  end

  def test_parse_comment_file
    comment = parser.comment.parse(comment_rip.read)
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
