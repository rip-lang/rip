module Rip::Compiler
  class Scope
    attr_reader :state
    attr_reader :outer_context

    def initialize(outer_context = {}, origin = nil)
      @state = {}
      @outer_context = outer_context
      @origin = origin
    end

    def ==(other)
      (state == other.state) &&
        (outer_context == other.outer_context)
    end

    def [](key)
      _key = key.to_s
      state[_key] || outer_context[_key]
    end

    def []=(key, value)
      _key = key.to_s

      if state.key?(_key)
        location = key.location if key.respond_to?(:location)
        raise Rip::Exceptions::CompilerException.new("#{key} has already been defined.", location, caller)
      else
        state[_key] = value
      end
    end

    def nested_context
      self.class.new(self)
    end

    def origin
      if @origin
        @origin
      elsif outer_context.respond_to?(:origin)
        outer_context.origin
      end
    end

    def symbols
      (keys + outer_context.keys).uniq
    end

    def to_s
      inspect
    end

    protected

    def keys
      state.keys
    end
  end
end
