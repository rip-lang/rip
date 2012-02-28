require_relative '../../test_case'

class ParsersObjectPropertyTest < TestCase
  def test_property_chain
    chain = parser.object.parse('0.one.two.three')
    assert_equal '0', chain[0][:integer]
    assert_equal 'one', chain[1][:reference]
    assert_equal 'two', chain[2][:reference]
    assert_equal 'three', chain[3][:reference]
  end

  def test_property_chain_invocation
    chain = parser.object.parse('zero().one().two().three()')
    assert_equal 'zero', chain[0][:invocation][:reference]
    assert_equal 'one', chain[1][:invocation][:reference]
    assert_equal 'two', chain[2][:invocation][:reference]
    assert_equal 'three', chain[3][:invocation][:reference]
  end
end
