require_relative '../../test_case'

class ParsersInvocationTest < TestCase
  def test_lambda_literal_invocation
    invocation = parser.invocation.parse('lambda () {}()')
    assert_equal [], invocation[:invocation][:arguments]
  end

  def test_lambda_reference_invocation
    invocation = parser.invocation.parse('full_name()')
    assert_equal 'full_name', invocation[:invocation][:reference]
    assert_equal [], invocation[:invocation][:arguments]
  end

  def test_lambda_reference_invocation_arguments
    invocation = parser.invocation.parse('full_name(:Thomas, :Ingram)')
    assert_equal 'full_name', invocation[:invocation][:reference]
    assert_equal 'Thomas', invocation[:invocation][:arguments].first[:string]
    assert_equal 'Ingram', invocation[:invocation][:arguments].last[:string]
  end

  def test_operator_invocation
    invocation = parser.invocation.parse('2 + 2')
    assert_equal '2', invocation[:invocation][:operand][:integer]
    assert_equal '+', invocation[:invocation][:operator][:reference]
    assert_equal '2', invocation[:invocation][:argument][:integer]
  end
end
