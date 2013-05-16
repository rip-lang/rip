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

  def raw_parse_tree(source_code)
    parser(source_code).raw_parse_tree
  end

  def parse_tree(source_code)
    parser(source_code).parse_tree
  end

  def syntax_tree(source_code)
    parser(source_code).syntax_tree
  end

  def rip_string(string)
    string.split('').map do |s|
      { :character => s }
    end
  end

  def rip_string_nodes(location, string)
    rip_string(string).inject([]) do |reply, character|
      last = reply.last
      _location = last.respond_to?(:location) ? last.location : location
      reply << Rip::Nodes::Character.new(_location.add_character, character[:character])
    end
  end

  # http://apidock.com/rails/String/strip_heredoc
  def strip_heredoc(string)
    indent = string.scan(/^[ \t]*(?=\S)/).min.size
    string.gsub(/^[ \t]{#{indent}}/, '')
  end

  def clean_inspect(ast)
    ast.inspect
      .gsub(/@\d+/, '')
      .gsub('\\"', '\'')
      .gsub(/:0x[0-9a-f]+/, '')
      .gsub('Rip::Nodes::', '')
      .gsub('Rip::Utilities::Location ', '')
      .gsub(/ @location=\#\<([^>]+)>/, '@\1')
  end
end
