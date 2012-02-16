require_relative '../test_case'

class ParserVariableLiteralTest < TestCase
  def test_variable
    [
      'name',
      'Person',
      '==',
      'save!',
      'valid?',
      'long_var-name',
      '*/-+<>&$~%'
    ].each do |variable|
      assert_equal variable, parser.variable.parse(variable)[:variable]
    end
  end

  def test_assignment
    assignment = parser.assignment.parse('favorite_language = :rip')
    assert_equal 'favorite_language', assignment[:assignment][:variable]
    assert_equal 'rip', assignment[:assignment][:value][:string]
  end
end
