module Rip
  module Utilities
    class Scope
      attr_reader :state
      attr_reader :outer_scope

      def initialize(state = {}, outer_scope = nil)
        @state = state
        @outer_scope = outer_scope
      end

      def get(key)
        state[key] || (outer_scope ? outer_scope.get(key) : nil)
      end

      def set(key, value)
        if state.key?(key)
          raise Rip::Exceptions::CompilerException.new("#{key} has already been defined.")
        else
          self.class.new(state.merge(key => value), outer_scope)
        end
      end

      def new(key, value)
        self.class.new({}, self)
      end

      def context
        outer_context.merge(state)
      end

      def outer_context
        outer_scope ? outer_scope.context : {}
      end
    end
  end
end
