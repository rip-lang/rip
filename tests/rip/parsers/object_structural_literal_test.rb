require_relative '../../test_case'

class ParsersObjectStructuralLiteralTest < TestCase
  def test_class
    klass = parser.class_literal.parse('class {}')
    assert_nil klass[:class][:ancestors]
    assert_equal [], klass[:class][:body]

    klass = parser.class_literal.parse('class () {}')
    assert_equal [], klass[:class][:ancestors]
    assert_equal [], klass[:class][:body]
  end

  def test_class_with_parent
    klass = parser.class_literal.parse('class (class () {}) {}')
    assert_equal 1, klass[:class][:ancestors].count
  end

  def test_lambda
    lamb = parser.lambda_literal.parse('lambda {}')
    assert_nil lamb[:lambda][:parameters]
    assert_equal [], lamb[:lambda][:body]

    lamb = parser.lambda_literal.parse('lambda () {}')
    assert_equal [], lamb[:lambda][:parameters]
    assert_equal [], lamb[:lambda][:body]
  end

  def test_lambda_with_parameter
    lamb = parser.lambda_literal.parse('lambda (name) {}')
    assert_equal 1, lamb[:lambda][:parameters].count
    assert_equal 'name', lamb[:lambda][:parameters].first[:reference]
  end

  def test_lambda_with_parameter_default
    lamb = parser.lambda_literal.parse('lambda (name = :rip) {}')
    assert_equal 1, lamb[:lambda][:parameters].count
    assert_equal 'name', lamb[:lambda][:parameters].first[:assignment][:reference]
    assert_equal 'rip', lamb[:lambda][:parameters].first[:assignment][:value][:string]
  end

  def test_lambda_with_parameter_and_parameter_default
    lamb = parser.lambda_literal.parse('lambda (platform, name = :rip) {}')
    assert_equal 2, lamb[:lambda][:parameters].count
    assert_equal 'platform', lamb[:lambda][:parameters].first[:reference]
    assert_equal 'name', lamb[:lambda][:parameters].last[:assignment][:reference]
  end
end
