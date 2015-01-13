module Rip::Compiler
  class Driver
    attr_reader :syntax_tree

    def initialize(syntax_tree)
      @syntax_tree = syntax_tree
    end

    def interpret(context = Rip::Compiler::Scope.global_context)
      syntax_tree.interpret(context)
    end
  end
end
