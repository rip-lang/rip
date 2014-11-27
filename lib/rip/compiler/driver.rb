module Rip::Compiler
  class Driver
    attr_reader :syntax_tree

    def initialize(syntax_tree)
      @syntax_tree = syntax_tree
    end

    def interpret(context = self.class.global_context)
      syntax_tree.interpret(context)
    end

    def self.global_context
      @global_context ||= Rip::Compiler::Scope.new({
        'System' => Rip::Core::System.type_instance,
        'true' => Rip::Core::Boolean.true,
        'false' => Rip::Core::Boolean.false
      })
    end
  end
end
