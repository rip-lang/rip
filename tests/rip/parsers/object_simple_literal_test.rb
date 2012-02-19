require_relative '../../test_case'

class ParsersObjectSimpleLiteralTest < TestCase
  def test_nil_literal
    n = parser.nil_literal.parse('nil')
    assert_equal 'nil', n[:nil]
  end

  def test_true_literal
    t = parser.boolean.parse('true')
    assert_equal 'true', t[:true]

    f = parser.boolean.parse('false')
    assert_equal 'false', f[:false]
  end

  def test_numeric
    integer = parser.numeric.parse('42')
    assert_equal '42', integer[:integer]

    decimal = parser.numeric.parse('4.2')
    assert_equal '4.2', decimal[:decimal]

    negative = parser.numeric.parse('-3')
    assert_equal '-3', negative[:integer]

    long = parser.numeric.parse('123_456_789')
    assert_equal '123_456_789', long[:integer]
  end

  def test_character
    character = parser.character.parse('`f')
    assert_equal 'f', character[:character]
  end

  def test_string
    symbol_string = parser.string.parse(':one')
    assert_equal 'one', symbol_string[:string]

    single_string = parser.string.parse('\'two\'')
    assert_equal 'two', single_string[:string]

    double_string = parser.string.parse('"three"')
    assert_equal 'three', double_string[:string]

    rip_doc = <<-RIP_DOC
<<HERE_DOC
here docs are good for multi-line strings
HERE_DOC
    RIP_DOC
    here_doc = parser.string.parse(rip_doc)
    assert_equal "here docs are good for multi-line strings\n", here_doc[:string]
  end

  def test_regular_expression
    regex = parser.regular_expression.parse('/hello/')
    assert_equal 'hello', regex[:regex]
  end
end
