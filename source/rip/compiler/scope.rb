module Rip::Compiler
  class Scope
    attr_reader :state
    attr_reader :outer_context

    def initialize(outer_context = {}, origin = nil)
      @state = {}
      @outer_context = outer_context
      @origin = origin.file? ? origin.dirname : origin if origin
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

    def nested_context(origin = nil)
      self.class.new(self, origin)
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

    def self.global_context
      @global_context ||= new(root_state, Pathname.pwd)
    end

    protected

    def keys
      state.keys
    end

    def self.root_state
      @root_state ||= Hash.new do |root, key|
        _key = key.to_s

        _reply = case _key
          when 'System' then Rip::Core::System.type_instance
          when 'true'   then Rip::Core::Boolean.true
          when 'false'  then Rip::Core::Boolean.false
        end

        root[_key] = _reply if _reply
      end.tap do |reply|
        def reply.keys
          %w[ System true false ]
        end
      end
    end
  end
end
