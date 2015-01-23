module Rip::Loaders
  class StandardIn < Rip::Loaders::Base
    def initialize
      @module_name = Pathname.pwd
      @load_path = Pathname.pwd
    end

    def parser
      @parser ||= Rip::Compiler::Parser.new(module_name, STDIN.read)
    end
  end
end
