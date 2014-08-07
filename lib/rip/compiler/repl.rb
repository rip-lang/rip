module Rip::Compiler
  class REPL
    def initialize
      @line_number = 0
    end

    def start
      context = Rip::Utilities::Scope.new(Rip::Compiler::Driver.global_context, :repl)

      print_welcome

      loop do
        line = prompt_for_line

        begin
          unless run_command(line, context)
            print_result(execute_source(line, context))
          end
        rescue Rip::Exceptions::Base => e
          warn e.dump
        rescue => e
          ee = Rip::Exceptions::NativeException.new(e, nil)
          warn ee.dump
        end
      end
    end

    def self.start
      new.start
    end

    protected

    def execute_source(line, context)
      line_parse_tree = Rip::Compiler::Parser.new(:repl, line)
      line_syntax_tree = line_parse_tree.syntax_tree

      line_syntax_tree.body.statements.map do |statement|
        statement.interpret(context)
      end.last
    end

    def run_command(line, context)
      case line.strip
        when 'exit'    then exit 0
        when 'help'    then print_help
        when 'symbols' then print_context(context)
        else return false
      end
      true
    end

    def print_help
      puts <<-MESSAGE
This should be a helpful message
      MESSAGE
    end

    def print_context(context, level = 0)
      reply = if context.respond_to?(:outer_context)
        print_context(context.outer_context, level + 1)
      else
        {}
      end

      if context.respond_to?(:symbols)
        reply.merge({ level => context.symbols })
      else
        reply
      end.tap do |all_symbols|
        if level.zero?
          all_symbols.entries.reverse.each do |level, symbols|
            puts symbols.join(', ') unless symbols.count.zero?
          end
        end
      end
    end

    def print_welcome
      puts <<-MESSAGE
#{Rip.logo}

Type "help" for help, "exit" to quit
      MESSAGE
    end

    def prompt_for_line(level = 1)
      puts
      print "[#{@line_number += 1}] module#{' >' * level} "
      STDIN.gets
    end

    def print_result(result)
      _result = result['to_string'].call([]).characters.map(&:data).join('')

      if result.is_a?(Rip::Core::String)
        puts _result.inspect
      else
        puts _result
      end
    end
  end
end
