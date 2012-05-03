require 'pathname'

require 'rip/parser'

# $ rip [run] <file>
# $ rip [repl]
# $ rip do [command] [arguments...]
# $ rip help [command]
# $ rip parse_tree <file>
# $ rip syntax_tree <file>
# $ rip version

module Rip
  class CLI
    def help(command = nil)
      if command
        if respond_to? command
          puts "TODO filll in something useful for #{command}"
        else
          run command
        end
      else
        puts 'TODO fill in something useful'
      end
    end

    def parse_tree(file)
      puts make_parse_tree(file)
    end

    def syntax_tree(file)
      puts make_syntax_tree(file)
    end

    def do(command, *args)
      make_syntax_tree(file).walk
    end

    def repl
      # TODO enter repl
      puts 'repl command not implemented yet'
    end

    # TODO enter repl if file is nil
    def run(file = nil)
      if file
        make_syntax_tree(file).walk
      else
        repl
      end
    end

    def self.start
      cli = new
      command = (ARGV.first || :help).to_sym

      if cli.respond_to? command
        cli.send command, *ARGV[1..-1]
      else
        cli.help
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
