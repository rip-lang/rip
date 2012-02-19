require_relative '../../test_case'

class ParsersBlockExpressionTest < TestCase
  def test_block
    block = parser.block.parse('{}')
    assert_equal [], block[:body]

    rip_block = <<-RIP_LIST
{
  # comment
  :words
}
    RIP_LIST
    block = parser.block.parse(rip_block.strip)
    assert_equal 2, block[:body].count
    assert_equal ' comment', block[:body].first[:comment]
    assert_equal 'words', block[:body].last[:string]
  end
end
