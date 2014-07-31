module Rip::Core
  class Overload < Rip::Core::Base
    attr_reader :parameters
    attr_reader :body

    def initialize(parameters, body)
      super()

      raise 'unexpanded overload (Rip::Core::Overload)' if parameters.any? { |p| p.is_a?(Rip::Nodes::DefaultParameter) }

      @parameters = parameters
      @body = body
    end

    def arity
      parameters.count
    end

    def bind
      if bound?
        self
      else
        self.class.new([ parameter_for_receiver, *parameters ], body)
      end
    end

    def call(calling_context, arguments)
      _body_context = body_context(calling_context, arguments)
      body.interpret(_body_context)
    end

    def callable?(context, argument_signature)
      return false unless parameters.count == argument_signature.count

      parameters.zip(argument_signature).all? do |(parameter, argument_type)|
        parameter.matches?(context, argument_type)
      end
    end

    def matches?(context, argument_signature)
      return false if parameters.count < argument_signature.count

      parameters.zip(argument_signature).all? do |(parameter, argument_type)|
        argument_type ? parameter.matches?(context, argument_type) : true
      end
    end

    protected

    def body_context(calling_context, arguments)
      parameters.zip(arguments).inject(calling_context.nested_context) do |_context, (parameter, argument)|
        parameter.bind(_context, argument)
      end
    end

    def bound?
      (parameters.count > 0) &&
        (parameters.first.name == '@')
    end

    def parameter_for_receiver
      Rip::Nodes::Parameter.new(nil, '@')
    end
  end
end

module Rip::Core
  class NativeOverload < Rip::Core::Overload
    def initialize(parameters, &body)
      raise 'unexpanded overload (Rip::Core::NativeOverload)' if parameters.any? { |p| p.is_a?(Rip::Nodes::DefaultParameter) }
      @parameters = parameters
      @body = body
    end

    def bind
      if bound?
        self
      else
        self.class.new([ parameter_for_receiver, *parameters ], &body)
      end
    end

    def call(calling_context, arguments)
      _body_context = body_context(calling_context, arguments)
      body.call(_body_context)
    end
  end
end
