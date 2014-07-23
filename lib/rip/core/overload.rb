module Rip::Core
  class Overload < Rip::Core::Base
    attr_reader :parameters
    attr_reader :body
    attr_reader :receiver

    def initialize(parameters, body)
      super()

      raise 'unexpanded overload (Rip::Core::Overload)' if parameters.any? { |p| p.is_a?(Rip::Nodes::DefaultParameter) }

      @parameters = parameters
      @body = body
    end

    def arity
      parameters.count
    end

    def bound?
      !!receiver
    end

    def bind(receiver)
      clone.tap do |reply|
        reply.instance_variable_set(:@receiver, receiver)
      end
    end

    def call(calling_context, arguments)
      _body_context = body_context(calling_context, arguments)
      body.interpret(_body_context)
    end

    protected

    def body_context(calling_context, arguments)
      parameters.zip(arguments).inject(calling_context.nested_context) do |_context, (parameter, argument)|
        parameter.bind(_context, argument)
      end
    end

    def clone
      self.class.new(parameters, body)
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

    def call(calling_context, arguments)
      _body_context = body_context(calling_context, arguments)
      body.call(_body_context)
    end

    protected

    def clone
      self.class.new(parameters, &body)
    end
  end
end
