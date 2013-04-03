{
  :raw_parse_tree => :parse_raw_as,
  :parse_tree => :parse_as
}.each do |parse_method, matcher|
  RSpec::Matchers.define matcher do |expected|
    english = parse_method.to_s.gsub('_', ' ').capitalize

    match do |parser|
      @source_code = parser.source_code
      @actual = parser.send(parse_method)
      @actual == expected
    end

    failure_message_for_should do |parser|
      <<-MESSAGE
#{english} is:
    #{@actual}
#{english} should be:
    #{expected}
Source:
#{@source_code}
      MESSAGE
    end

    failure_message_for_should_not do |parser|
      <<-MESSAGE
#{english} should not be:
    #{expected}
Source:
#{@source_code}
      MESSAGE
    end
  end
end


RSpec::Matchers.define :not_parse do
  match do |parser|
    parser.raw_parse_tree.nil?
  end
end
