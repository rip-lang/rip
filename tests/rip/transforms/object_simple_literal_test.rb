require_relative '../../test_case'

require 'rip/nodes/character'
require 'rip/nodes/decimal'
require 'rip/nodes/integer'
require 'rip/nodes/string'
require 'rip/nodes/regular_expression'

class TransformObjectSimpleLiteralTest < TestCase
  def test_numeric
    integer = ast('42').first
    assert_equal Rip::Nodes::Integer.new('42'), integer

    decimal = ast('4.2').first
    assert_equal Rip::Nodes::Decimal.new('4.2'), decimal

    negative = ast('-3').first
    assert_equal Rip::Nodes::Integer.new('-3'), negative

    long = ast('123_456_789').first
    assert_equal Rip::Nodes::Integer.new('123_456_789'), long
  end

  def test_character
    character = ast('`f').first
    assert_equal Rip::Nodes::Character.new('f'), character
  end

  def test_string
    symbol_string = ast(':one').first
    assert_equal Rip::Nodes::String.new('one'), symbol_string

    single_string = ast('\'two\'').first
    assert_equal Rip::Nodes::String.new('two'), single_string

    double_string = ast('"three"').first
    assert_equal Rip::Nodes::String.new('three'), double_string

    rip_doc = <<-RIP_DOC
<<HERE_DOC
here docs are good for multi-line strings
HERE_DOC
    RIP_DOC
    here_doc = ast(rip_doc).first
    assert_equal Rip::Nodes::String.new("here docs are good for multi-line strings\n"), here_doc
  end

  def test_regular_expression
    regex = ast('/hello/').first
    assert_equal Rip::Nodes::RegularExpression.new('hello'), regex
  end
end
