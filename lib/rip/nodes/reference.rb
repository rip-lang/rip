module Rip::Nodes
  class Reference < Base
    attr_reader :name

    def initialize(location, name)
      super(location)
      @name = name.to_s
    end

    def ==(other)
      super &&
        (name == other.name)
    end

    def interpret(context)
      context[name] ||
        (raise Rip::Exceptions::RuntimeException.new("Unknown reference `#{name}`"))
    end

    def interpret_for_assignment(context, &block)
      context[name] = block.call
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{name})" ]
      ]
    end
  end
end
