require_relative '../../test_case'

class ParsersSimpleExpressionTest < TestCase
  def test_simple_expression
    if_postfix = parser.simple_expression.parse(':rip if (true)')
    assert_equal 'rip', if_postfix[:string]
    assert_equal 'true', if_postfix[:if_postfix][:binary_condition][:true]

    unless_postfix = parser.simple_expression.parse('run() unless (false)')
    assert_equal 'run', unless_postfix[:invocation][:reference]
    assert_equal [], unless_postfix[:invocation][:arguments]
    assert_equal 'false', unless_postfix[:unless_postfix][:binary_condition][:false]
  end
end
