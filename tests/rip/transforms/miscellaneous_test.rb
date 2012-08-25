require_relative '../../test_case'

require 'rip/nodes/comment'
require 'rip/nodes/nil'

class TransformMiscellaneousTest < TestCase
  def test_empty
    empty = ast('').first
    assert_equal Rip::Nodes::Nil, empty
  end

  def test_comment
    comment = ast('# this is a comment').first
    assert_equal Rip::Nodes::Comment.new(' this is a comment'), comment
  end
end
