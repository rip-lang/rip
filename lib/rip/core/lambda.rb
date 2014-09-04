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

      self['class'] = self.class.class_instance
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
      self.class.new(context, overloads.map(&:bind), applied_arguments).tap do |reply|
        reply['@'] = Rip::Core::DynamicProperty.new(!receiver.is_a?(self.class)) do
          receiver
        end
      end
    end

    def call(arguments)
      _arguments = if bound?
        [ self['@'], *applied_arguments, *arguments ]
      else
        applied_arguments + arguments
      end

      full_signature = _arguments.map { |arg| arg['class'] }

      overload = overloads.detect do |overload|
        overload.callable?(context.nested_context, full_signature)
      end

      if overload
        overload.call(calling_context, _arguments)
      else
        apply(full_signature, arguments)
      end
    end

    define_class_instance do |class_instance|
      to_string_overload = Rip::Core::NativeOverload.new([
      ]) do |context|
        overloads = context['@'].overloads.map do |overload|
          parameters = overload.parameters.map do |parameter|
            "#{parameter.name}<#{parameter.raw_type || Rip::Core::Object.class_instance}>"
          end

          "\t-> (#{parameters.join(', ')}) { ... }"
        end

        Rip::Core::String.from_native(<<-LAMBDA)
=> {
#{overloads.join("\n")}
}
        LAMBDA
      end
      class_instance['@']['to_string'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ to_string_overload ])

      def class_instance.to_s
        '#< System.Lambda >'
      end
    end

    protected

    def apply(full_signature, arguments)
      matching_overloads = overloads.select do |overload|
        overload.matches?(context.nested_context, full_signature)
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

    def calling_context
      context.nested_context.tap do |reply|
        reply['@'] = self['@'] if bound?
        reply['self'] = self
      end
    end
  end
end
