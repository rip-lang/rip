module Rip::Loaders
  class Base
    attr_reader :module_name
    attr_reader :load_path

    def context
      Rip::Compiler::Scope.global_context.nested_context(load_path)
    end

    def load
      if parser
        parser.syntax_tree.interpret(context)
      else
        raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`", nil, caller)
      end
    end
  end
end
