module Rip::Loaders
  class FileSystem
    attr_reader :module_name
    attr_reader :load_paths

    def initialize(module_name, load_paths)
      @module_name = module_name
      @load_paths = load_paths
    end

    def load
      _qualified_module_name = qualified_module_name

      if _qualified_module_name
        syntax_tree = Rip::Compiler::Parser.new(module_name, _qualified_module_name.read).syntax_tree
        Rip::Compiler::Driver.new(syntax_tree).interpret
      end
    end

    def qualified_module_name
      load_paths.inject([]) do |memo, path|
        memo + [
          (path + module_name).expand_path,
          (path + "#{module_name}.rip").expand_path
        ]
      end.detect(&:file?)
    end

    def self.load_module(module_name)
      new(module_name, [ Pathname('.').expand_path ]).load
    end
  end
end
