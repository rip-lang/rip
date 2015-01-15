module Rip::Loaders
  class FileSystem < Rip::Loaders::Base
    def initialize(module_name)
      @_module_name = module_name
      @load_path = module_name.parent
    end

    def module_name
      reply = [
        @_module_name,
        @_module_name.sub_ext('.rip')
      ].detect(&:file?)

      reply ? reply.expand_path : @_module_name
    end

    def parser
      Rip::Compiler::Parser.new(module_name, module_name.read) if module_name.file?
    end
  end
end
