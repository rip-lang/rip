require_relative '../../test_case'

require 'rip/parsers/construct'

class ParsersConstructTest < TestCase
  def setup
    super
    Rip::Parser.send :include, Rip::Parsers::Construct
  end

  def test_if_condition
    if_condition = parser.if_condition.parse('if (true)')
    assert_equal 'true', if_condition[:binary_condition][:true]
  end

  def test_unless_condition
    unless_condition = parser.unless_condition.parse('unless (false)')
    assert_equal 'false', unless_condition[:binary_condition][:false]
  end
end
