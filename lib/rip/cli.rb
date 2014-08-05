require 'thor'

module Rip
  class CLI < Thor
    class_option :verbose, :type => :boolean, :default => false, :desc => 'Make Rip chatty'

    default_task :execute

    map '--version' => :version

    desc 'execute [file]', 'Read and execute [file] (or standard in)'
    def execute(file = nil)
      wrap_exceptions do
        Rip::Compiler::Driver.new(syntax_tree(file)).interpret
      end
    end

    desc 'repl', 'Enter read, evaluate, print loop'
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

    desc 'version', 'Print the version'
    def version
      puts Rip::Version.to_s(options[:verbose])
    end

    desc 'debug [file]', 'Print the compiler information for [file] (or standard in)'
    option :tree, :required => true, :aliases => ['-t'], :desc => 'Type of tree to output. Must be one of `raw_parse`, `parse`, `syntax`'
    def debug(file = nil)
      valid_trees = Hash.new do |valid, unknown_tree|
        message = "Unknown argument for option --tree \"#{unknown_tree}\". Please specify one of the following: #{valid.keys.join(', ')}"
        raise Rip::Exceptions::UsageException.new(message, nil)
      end.merge({
        'raw_parse'  => :raw_parse_tree,
        'parse'  => :parse_tree,
        'syntax' => :syntax_tree
      })

      output = wrap_exceptions do
        send(valid_trees[options[:tree]], file).to_debug.map do |(level, node)|
          "#{"\t" * level}#{node}"
        end
      end

      puts output
    end

    protected

    def load_source_code(origin)
      resolve_origin(origin).read
    end

    def resolve_origin(origin)
      if origin.nil?
        STDIN
      else
        Rip.project_path.join(origin).expand_path
      end
    end

    def parser(origin)
      Rip::Compiler::Parser.new(resolve_origin(origin), load_source_code(origin))
    end

    def raw_parse_tree(origin)
      parser(origin).raw_parse_tree
    end

    def parse_tree(origin)
      parser(origin).parse_tree
    end

    def syntax_tree(origin)
      parser(origin).syntax_tree
    end

    def wrap_exceptions(&block)
      begin
        block.call
      rescue Rip::Exceptions::Base => e
        warn e.dump
        exit e.status_code
      rescue => e
        ee = Rip::Exceptions::NativeException.new(e, nil)
        warn ee.dump
        exit ee.status_code
      end
    end

    def wip(command)
      puts "`#{command}` command not implemented yet"
    end
  end
end
