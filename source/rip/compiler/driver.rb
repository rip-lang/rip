module Rip::Compiler
  class Driver
    attr_reader :syntax_tree

    def initialize(syntax_tree)
      @syntax_tree = syntax_tree
    end

    def interpret(context = self.class.global_context)
      syntax_tree.interpret(context)
    end

    def self.global_context
      @global_context ||= Rip::Compiler::Scope.new(root_state)
    end

    protected

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
