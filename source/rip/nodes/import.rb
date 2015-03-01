module Rip::Nodes
  class Import < Rip::Nodes::Base
    attr_reader :module_name

    def initialize(location, module_name)
      super(location)
      @module_name = module_name.characters.map(&:data).join('')
    end
  end
end
