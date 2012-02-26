require_relative '../../test_case'

class ParsersBlockExpressionTest < TestCase
  def test_if_prefix
    if_prefix = parser.if_prefix.parse('if (true) {}')
    assert_equal 'true', if_prefix[:if_prefix][:binary_condition][:reference][:true]
    assert_equal [], if_prefix[:if_prefix][:body]

    if_else_prefix = parser.if_prefix.parse('if (true) {} else {}')
    assert_equal [], if_else_prefix[:if_prefix][:body]
    assert_equal [], if_else_prefix[:if_prefix][:else][:body]
  end

  def test_unless_prefix
    unless_prefix = parser.unless_prefix.parse('unless (true) {}')
    assert_equal 'true', unless_prefix[:unless_prefix][:binary_condition][:reference][:true]
    assert_equal [], unless_prefix[:unless_prefix][:body]

    unless_else_prefix = parser.unless_prefix.parse('unless (true) {} else {}')
    assert_equal [], unless_else_prefix[:unless_prefix][:body]
    assert_equal [], unless_else_prefix[:unless_prefix][:else][:body]
  end

  def test_switch
    switch = parser.switch.parse('switch { case (:rip) {} }')
    assert_nil switch[:switch][:switch_test]
    assert_equal 1, switch[:switch][:body].count
    assert_equal 'rip', switch[:switch][:body].first[:case][:case_qualifiers].first[:string]
    assert_equal [], switch[:switch][:body].first[:case][:body]
  end

  def test_switch_full
    rip_switch = <<-RIP_SWITCH
switch (favorite_language) {
  case (:rip) {
  }
  else {
  }
}
    RIP_SWITCH
    switch = parser.switch.parse(rip_switch.strip)
    assert_equal 'favorite_language', switch[:switch][:switch_test][:reference]
    assert_equal 2, switch[:switch][:body].count
    assert_equal 'rip', switch[:switch][:body].first[:case][:case_qualifiers].first[:string]
    assert_equal [], switch[:switch][:body].first[:case][:body]
    assert_equal [], switch[:switch][:body].last[:else][:body]
  end

  def test_exception_handling
    rip = <<-RIP
try {
}
catch (Exception: e) {
}
finally {
}
    RIP
    tcf = parser.exception_handling.parse(rip.strip)
    assert_equal [], tcf[:exception_handling][0][:try][:body]
    assert_equal 'Exception', tcf[:exception_handling][1][:catch][:key][:reference]
    assert_equal 'e', tcf[:exception_handling][1][:catch][:value][:reference]
    assert_equal [], tcf[:exception_handling][1][:catch][:body]
    assert_equal [], tcf[:exception_handling][2][:finally][:body]
  end

  def test_block
    block = parser.block.parse('{}')
    assert_equal [], block[:body]

    rip_block = <<-RIP_LIST
{
  # comment
  :words
}
    RIP_LIST
    block = parser.block.parse(rip_block.strip)
    assert_equal 2, block[:body].count
    assert_equal ' comment', block[:body].first[:comment]
    assert_equal 'words', block[:body].last[:string]
  end
end
