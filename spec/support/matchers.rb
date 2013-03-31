RSpec::Matchers.define :parse_as do |expected|
  match do |parser|
    @source_code = parser.source_code
    @actual = parser.parse_tree
    @actual == expected
  end

  failure_message_for_should do |actual|
    <<-MESSAGE
Parse tree is:
    #{@actual}
Parse tree should be:
    #{expected}
Source:
#{@source_code}
    MESSAGE
  end

  failure_message_for_should_not do |actual|
    <<-MESSAGE
Parse tree should not be:
    #{expected}
Source:
#{@source_code}
    MESSAGE
  end
end


RSpec::Matchers.define :not_parse do
  match do |actual|
    actual.parse_tree.nil?
  end
end
