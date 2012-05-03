require 'pathname'

require 'rip/parser'

# $ rip <file>
# $ rip run <file>
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
      tree = Rip::Parser.new.parse_file Pathname(file).expand_path
      puts tree
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
  end
end
