require 'pathname'
require 'thor'

require 'rip/parser'

module Rip
  class CLI < Thor
    default_task :execute

    desc 'help [task]', 'Describe available tasks or one specific [task]'
    def help(*args)
      general_usage = <<-USAGE
Usage:
  rip <task> <required-argument> [option-argument] [--options...]

      USAGE
      puts general_usage if args.empty?
      super
    end

    desc 'parse_tree <file>', 'Print the parse tree for <file> and exit'
    def parse_tree(file)
      puts make_parse_tree(file)
    end

    desc 'syntax_tree <file>', 'Print the syntax tree for <file> and exit'
    def syntax_tree(file)
      puts make_syntax_tree(file)
    end

    desc 'do <command> [arguments...]', 'Execute specified <command>, similar to Ruby\'s rake'
    def do(command, *args)
      make_syntax_tree(file).walk
    end

    desc '[repl]', 'Enter read, evaluate, print loop'
    def repl
      # TODO enter repl
      puts 'repl command not implemented yet'
    end

    desc '<file>', 'Read and execute <file>'
    def execute(file = nil)
      if file
        make_syntax_tree(file).walk
      else
        repl
      end
    end

    protected

    def make_parse_tree(filename)
      Rip::Parser.new.parse_file(Rip.project_path.join(filename).expand_path)
    end

    def make_syntax_tree(filename)
      make_parse_tree(filename).to_ast
    end
  end
end
