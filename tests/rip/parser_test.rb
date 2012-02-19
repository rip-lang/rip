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
end
