module Rip::Loaders
  class Base
    attr_reader :module_name
    attr_reader :load_path

    def context
      Rip::Compiler::Scope.new(Rip::Compiler::Scope.global_context, load_path)
    end

    def load
      syntax_tree = parser.syntax_tree

      if syntax_tree
        syntax_tree.interpret(context)
      else
        raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`", nil, caller)
      end
    end
  end
end
