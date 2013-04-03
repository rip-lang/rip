module RSpecHelpers
  def recognizes_as_expected(description, *flags, &block)
    context description, *flags do
      instance_exec &block
      specify do
        if defined? expected_raw
          expect(parser(rip)).to parse_raw_as(expected_raw)
        end

        if defined? expected
          expect(parser(rip)).to parse_as(expected)
        end
      end
    end
  end

  def profile_parslet(rip, parslet = :lines)
    result = RubyProf.profile do
      parser(rip).send(parslet).parse_tree
    end

    result.eliminate_methods!([
      /Array/,
      /Class/,
      /Enumerable/,
      /Fixnum/,
      /Hash/,
      /Kernel/,
      /Module/,
      /Object/,
      /Proc/,
      /Regexp/,
      /String/,
      /Symbol/
    ])

    tree = RubyProf::CallInfoPrinter.new(result)
    tree.print(STDOUT)
  end

  def samples_path
    Pathname("#{__FILE__}/../fixtures").expand_path
  end

  def new_location(origin, offset, line, column)
    Rip::Utilities::Location.new(origin, offset, line, column)
  end

  def location_for(options = {})
    origin = options[:origin] || :rspec
    offset = options[:offset] || 0
    line = options[:line] || 1
    column = options[:column] || 1
    new_location(origin, offset, line, column)
  end

  def parser(source_code)
    Rip::Compiler::Parser.new(:rspec, source_code)
  end

  def syntax_tree(code)
    parser(code).syntax_tree
  end

  def rip_parsed_string(string)
    string.split('').map do |s|
      { :raw_string => s }
    end
  end

  # http://apidock.com/rails/String/strip_heredoc
  def strip_heredoc(string)
    indent = string.scan(/^[ \t]*(?=\S)/).min.size
    string.gsub(/^[ \t]{#{indent}}/, '')
  end
end
