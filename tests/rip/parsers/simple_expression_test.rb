require_relative '../../test_case'

class ParsersSimpleExpressionTest < TestCase
  def test_simple_expression_a
    a = parser.simple_expression.parse('return unless (false);')
    assert_equal 'return', a[:return_keyword]
    assert_equal 'false', a[:unless_postfix][:binary_condition][:reference][:false]
  end

  def test_simple_expression_b
    b = parser.simple_expression.parse('return;')
    assert_equal 'return', b[:return_keyword]
  end

  def test_simple_expression_c
    c = parser.simple_expression.parse('exit 1 if (:error)')
    assert_equal 'exit', c[:exit_keyword]
    assert_equal '1', c[:integer]
    assert_equal 'error', c[:if_postfix][:binary_condition][:string]
  end

  def test_simple_expression_d
    d = parser.simple_expression.parse('exit 0')
    assert_equal 'exit', d[:exit_keyword]
    assert_equal '0', d[:integer]
  end

  def test_simple_expression_e
    e = parser.simple_expression.parse('nil if (empty());')
    assert_equal 'nil', e[:reference][:nil]
    assert_equal 'empty', e[:if_postfix][:binary_condition][:invocation][:reference]
    assert_equal [], e[:if_postfix][:binary_condition][:invocation][:arguments]
  end

  def test_simple_expression_f
    f = parser.simple_expression.parse('[]')
    assert_equal [], f[:list]
  end
end
