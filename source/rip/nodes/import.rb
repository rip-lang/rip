module Rip::Nodes
  class Import < Rip::Nodes::Base
    attr_reader :module_name

    def initialize(location, module_name)
      super(location)
      @module_name = module_name.characters.map(&:data).join('')
    end

    def interpret(context)
      Rip::Loaders::FileSystem.new(target).load
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{target})" ]
      ]
    end

    protected

    def target
      if location.origin.directory?
        location.origin
      else
        location.origin.dirname
      end + module_name
    end
  end
end
