module Rip::Utilities
  class Scope
    attr_reader :state
    attr_reader :outer_context

    def initialize(outer_context = {})
      @state = {}
      @outer_context = outer_context
    end

    def ==(other)
      (state == other.state) &&
        (outer_context == other.outer_context)
    end

    def [](key)
      state[key] || outer_context[key]
    end

    def []=(key, value)
      if state.key?(key)
        location = key.location if key.respond_to?(:location)
        raise Rip::Exceptions::CompilerException.new("#{key} has already been defined.", location, caller)
      else
        state[key] = value
      end
    end

    def nested_context
      self.class.new(self)
    end
  end
end
