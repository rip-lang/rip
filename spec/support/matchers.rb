RSpec::Matchers.define :parse_as do |expected|
  match do |parser|
    @source_code = parser.source_code
    @actual = parser.parse_tree
    @actual == expected
  end

  failure_message_for_should do |actual|
    strip_heredoc(<<-MESSAGE)
      Expected parse tree to be #{expected}, but was #{@actual} instead. Source was:
      #{@source_code}
    MESSAGE
  end

  failure_message_for_should_not do |actual|
    strip_heredoc(<<-MESSAGE)
      Expected parse tree to not be #{expected}, but it was. Source was:
      #{@source_code}
    MESSAGE
  end
end

RSpec::Matchers.define :parse_first_as do |expected|
  match do |parser|
    @source_code = parser.source_code
    @actual = parser.parse_tree.first
    @actual == expected
  end

  failure_message_for_should do |actual|
    strip_heredoc(<<-MESSAGE)
      Expected first leaf in parse tree to be #{expected}, but was #{@actual} instead. Source was:
      #{@source_code}
    MESSAGE
  end

  failure_message_for_should_not do |actual|
    strip_heredoc(<<-MESSAGE)
      Expected first leaf in parse tree to not be #{expected}, but it was. Source was:
      #{@source_code}
    MESSAGE
  end
end

RSpec::Matchers.define :not_parse do
  match do |actual|
    actual.parse_tree.nil?
  end
end
