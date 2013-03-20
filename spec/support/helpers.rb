module RSpecHelpers
  def samples_path
    Pathname("#{__FILE__}/../fixtures").expand_path
  end

  def new_location(origin, absolute_position, line, position)
    Rip::Utilities::Location.new(origin, absolute_position, line, position)
  end

  def location_for(options = {})
    origin = options[:origin] || :rspec
    absolute_position = options[:absolute_position] || 0
    line = options[:line] || 1
    position = options[:position] || 0
    new_location(origin, absolute_position, line, position)
  end

  def parser
    Rip::Compiler::Parser.new
  end

  def apt(code)
    parser.parse(code)
  end

  def ast(code)
    Rip::Compiler::AST.new(apt(code)).tree
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
