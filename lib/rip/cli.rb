require 'pathname'
require 'thor'

require 'rip/ast'
require 'rip/parser'
require 'rip/version'

module Rip
  class CLI < Thor
    class_option :verbose, :type => :boolean, :default => false, :desc => 'Make Rip chatty'

    default_task :execute

    map '--version' => :version

    desc '<file>', 'Read and execute <file>'
    def execute(file = nil)
      wip :execute
      file ? make_syntax_tree(file).evaluate : repl
    end

    desc '[repl]', 'Enter read, evaluate, print loop'
    def repl
      wip :repl
    end

    desc 'help [task]', 'Describe available tasks or one specific [task]'
    def help(*args)
      general_usage = <<-USAGE
Usage:
  rip <task> <required-argument> [option-argument] [--options...]

      USAGE
      puts general_usage if args.empty?
      super
    end

    desc 'do <command> [arguments...]', 'Execute specified <command>, similar to Ruby\'s rake'
    def do(command, *args)
      wip :do
    end

    desc 'version', 'Print the version and exit'
    def version
      puts Rip::Version.to_s(options[:verbose])
    end

    desc 'parse_tree <file>', 'Print the parse tree for <file> and exit'
    def parse_tree(file)
      wip :parse_tree
      puts make_parse_tree(file).inspect
    end

    desc 'syntax_tree <file>', 'Print the syntax tree for <file> and exit'
    def syntax_tree(file)
      wip :syntax_tree
      puts make_syntax_tree(file).inspect
    end

    protected

    def make_parse_tree(filename)
      Rip::Parser.new.parse_file(Rip.project_path.join(filename).expand_path)
    end

    def make_syntax_tree(filename)
      Rip::AST.new make_parse_tree(filename)
    end

    def wip(command)
      puts "`#{command}` command not implemented yet"
    end
  end
end
