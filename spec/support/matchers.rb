RSpec::Matchers.define :parse_as do |expected|
  match do |parser|
    @actual = parser.parse_tree
    @actual == expected
  end

  failure_message_for_should do |actual|
    "expected parse_tree to be #{expected}, but was #{@actual} instead"
  end

  failure_message_for_should_not do |actual|
    "expected parse_tree to not be #{expected}, but it was"
  end
end

RSpec::Matchers.define :parse_first_as do |expected|
  match do |parser|
    @actual = parser.parse_tree.first
    @actual == expected
  end

  failure_message_for_should do |actual|
    "expected parse_tree.first to be #{expected}, but was #{@actual} instead"
  end

  failure_message_for_should_not do |actual|
    "expected parse_tree.first to not be #{expected}, but it was"
  end
end

RSpec::Matchers.define :not_parse do
  match do |actual|
    actual.parse_tree.nil?
  end
end
