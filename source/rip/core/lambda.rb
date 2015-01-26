module Rip::Core
  class Lambda < Rip::Core::Base
    attr_reader :context
    attr_reader :overloads
    attr_reader :applied_arguments

    def initialize(context, overloads, applied_arguments = [])
      super()

      @context = context
      @overloads = overloads
      @applied_arguments = applied_arguments

      self['type'] = self.class.type_instance
    end

    def to_s_prep_body
      super + [
        "arity = [ #{arity.join(', ')} ]"
      ]
    end

    def arity
      overloads.inject([]) do |memo, overload|
        [ *memo, overload.arity ]
      end.uniq.sort
    end

    def bind(receiver)
      _overloads = overloads.map do |overload|
        overload.bind(receiver)
      end

      self.class.new(context, _overloads, applied_arguments).tap do |reply|
        reply['@'] = Rip::Core::DynamicProperty.new(!receiver.is_a?(self.class)) do |_|
          receiver
        end
      end
    end

    def call(invocation_context, arguments)
      _arguments = if bound?
        [ self['@'], *applied_arguments, *arguments ]
      else
        applied_arguments + arguments
      end

      full_signature = _arguments.map { |arg| arg['type'] }

      overload = overloads.detect do |overload|
        overload.callable?(full_signature)
      end

      if overload
        overload.call(calling_context(invocation_context), _arguments)
      else
        apply(full_signature, arguments)
      end
    end

    define_type_instance do |type_instance|
      type_instance['@']['apply'] = Rip::Core::DelayedProperty.new do |this|
        apply_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('args', Rip::Core::List.type_instance)
        ]) do |context|
          arguments = context['args'].items

          _this = context['@']

          _arguments = if _this.send(:bound?)
            [ _this['@'], *_this.applied_arguments, *arguments ]
          else
            _this.applied_arguments + arguments
          end

          full_signature = _arguments.map { |arg| arg['type'] }

          _this.send(:apply, full_signature, arguments)
        end

        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ apply_overload ])
      end

      type_instance['@']['bind'] = Rip::Core::DelayedProperty.new do |_|
        bind_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('@@', Rip::Core::Object.type_instance)
        ]) do |context|
          context['@'].bind(context['@@'])
        end

        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ bind_overload ])
      end

      type_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          this = context['@']

          overloads = this.overloads.map do |overload|
            applied_arguments_count = if this.send(:bound?)
              this.applied_arguments.count + 1
            else
              this.applied_arguments.count
            end

            unapplied_parameters = overload.parameters[applied_arguments_count..-1] || []

            parameters = unapplied_parameters.map do |parameter|
              "#{parameter.name}<#{parameter.type}>"
            end

            "\t-> (#{parameters.join(', ')}) { ... }"
          end

          Rip::Core::String.from_native(<<-LAMBDA)
=> {
#{overloads.join("\n")}
}
          LAMBDA
        end

        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System.Lambda >'
      end
    end

    protected

    def apply(full_signature, arguments)
      matching_overloads = overloads.select do |overload|
        overload.matches?(full_signature)
      end

      if matching_overloads.count > 0
        self.class.new(context, matching_overloads, applied_arguments + arguments).tap do |reply|
          reply['@'] = self['@'] if bound?
        end
      elsif arguments.count.zero?
        self
      else
        raise 'cannot find overload for arguments given'
      end
    end

    def bound?
      properties.key?('@')
    end

    def calling_context(invocation_context)
      Rip::Compiler::Scope.new(context, invocation_context.origin).tap do |reply|
        reply['@'] = self['@'] if bound?
        reply['self'] = self
      end
    end
  end
end
