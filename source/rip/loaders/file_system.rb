module Rip::Loaders
  class FileSystem < Rip::Loaders::Base
    def initialize(module_name)
      @module_name = [
        module_name,
        Pathname.new("#{module_name}.rip")
      ].detect(&:file?).expand_path
      @load_path = self.module_name.parent
    end

    def parser
      Rip::Compiler::Parser.new(module_name, module_name.read)
    end
  end
end
