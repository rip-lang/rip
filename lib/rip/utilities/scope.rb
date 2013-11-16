module Rip::Utilities
  class Scope
    attr_reader :state
    attr_reader :outer_scope

    def initialize(state = {}, outer_scope = nil)
      @state = state
      @outer_scope = outer_scope
    end

    def [](key)
      state[key] || (outer_scope ? outer_scope.get(key) : nil)
    end

    def []=(key, value)
      if state.key?(key)
        location = key.location if key.respond_to?(:location)
        raise Rip::Exceptions::CompilerException.new("#{key} has already been defined.", location, caller)
      else
        state[key] = value
      end
    end

    def nested_context(new_state = {})
      self.class.new(new_state, self)
    end

    def context
      outer_context.merge(state)
    end

    def outer_context
      outer_scope ? outer_scope.context : {}
    end
  end
end
