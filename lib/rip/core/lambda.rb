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
      @applied_overloads = {}

      self['class'] = self.class.class_instance
    end

    def to_s_prep_body
      super + [
        "arity = [ #{arity.join(', ')} ]"
      ]
    end

    def all_arguments(arguments)
      applied_arguments + arguments
    end

    def arity
      overloads.inject([]) do |memo, overload|
        [ *memo, overload.arity ]
      end.uniq.sort
    end

    def bind(receiver)
      Rip::Core::BoundLambda.new(receiver, context, overloads, applied_arguments)
    end

    def call(arguments)
      _arguments = all_arguments(arguments)

      argument_signature = _arguments.map { |arg| arg['class'] }

      matching_overloads = argument_signature.inject(overloads) do |potential_overloads, argument_type|
        index = argument_signature.index(argument_type)

        potential_overloads.select do |potential|
          parameter = potential.parameters[index]
          parameter && parameter.matches?(context, argument_type)
        end
      end

      low, *, high = arity
      shortest_parameters_count = [ minimal_arguments_count, low ].min
      longest_parameters_count = [ minimal_arguments_count, (high || low) ].max

      if (shortest_parameters_count > minimal_arguments_count) && arguments.count.zero?
        warn <<-WARNING
lambda called with no arguments, but all overloads require at least #{shortest_parameters_count} arguments
instead of synthesizing a new lambda with nothing applied, called lambda will be returned
        WARNING
        return self
      end

      if _arguments.count > longest_parameters_count
        raise 'too many arguments. called lambda has no overload so many parameters'
      end

      if matching_overloads.count.zero?
        raise 'cannot find overload for arguments given'
      end

      if matching_overloads.count > 1
        return apply(matching_overloads, _arguments)
      end

      if matching_overloads.count == 1
        matched_overload = matching_overloads.first

        if matched_overload.parameters.count == _arguments.count
          matched_overload.call(calling_context, _arguments)
        else
          apply(matching_overloads, _arguments)
        end
      end
    end

    def minimal_arguments_count
      0
    end

    define_class_instance do |class_instance|

      def class_instance.to_s
        '#< System.Lambda >'
      end
    end

    protected

    def apply(matching_overloads, applied_arguments)
      self.class.new(context, matching_overloads, applied_arguments)
    end

    def calling_context
      context.nested_context.tap do |reply|
        reply['self'] = self
      end
    end
  end

  class BoundLambda < Rip::Core::Lambda
    attr_reader :receiver

    def initialize(receiver, context, overloads, applied_arguments = [])
      super(context, overloads, applied_arguments)
      @receiver = receiver
    end


    def calling_context
      super.tap do |reply|
        reply['@'] = receiver
      end
    end



    protected

    def apply(matching_overloads, applied_arguments)
      self.class.new(receiver, context, matching_overloads, applied_arguments)
    end
  end

  class DynamicProperty
    attr_reader :block

    def initialize(&block)
      @block = block
    end
  end
end
