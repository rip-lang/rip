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

    failure_message do |parser|
      <<-MESSAGE
#{english} is:
    #{@actual}
#{english} should be:
    #{expected}
Source:
#{@source_code}
      MESSAGE
    end

    failure_message_when_negated do |parser|
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


RSpec::Matchers.define :output_as do |expected, filename = 'sample.rip'|
  match do |source|
    write_file filename, source

    run_simple "rip execute #{filename}"

    @expected = expected
    @actual = all_stdout

    @actual == @expected
  end
end
