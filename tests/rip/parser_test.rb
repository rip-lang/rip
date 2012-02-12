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
end
