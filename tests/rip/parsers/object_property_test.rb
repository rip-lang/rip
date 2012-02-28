require_relative '../../test_case'

class ParsersObjectPropertyTest < TestCase
  def test_property_chain
    chain = parser.object.parse('0.one.two.three')
    assert_equal '0', chain[:integer]
    assert_equal 'one', chain[:property_chain][0][:reference]
    assert_equal 'two', chain[:property_chain][1][:reference]
    assert_equal 'three', chain[:property_chain][2][:reference]
  end

  def test_property_chain_invocation
    chain = parser.object.parse('zero().one().two().three()')
    assert_equal 'zero', chain[:invocation][:reference]
    assert_equal 'one', chain[:property_chain][0][:invocation][:reference]
    assert_equal 'two', chain[:property_chain][1][:invocation][:reference]
    assert_equal 'three', chain[:property_chain][2][:invocation][:reference]
  end
end
