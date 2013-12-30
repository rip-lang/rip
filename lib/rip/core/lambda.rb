module Rip::Core
  class Lambda < Rip::Core::Base
    attr_reader :context
    attr_reader :keyword
    attr_reader :parameters
    attr_reader :body

    def initialize(context, keyword, parameters, body)
      super()

      @context = context
      @keyword = keyword
      @parameters = parameters
      @body = body

      self['class'] = self.class.class_instance
    end

    def call(calling_context, arguments)
      required_parameters =  parameters.select { |parameter| parameter.is_a?(Rip::Nodes::Reference) }

      if required_parameters.count > arguments.count
        curry(calling_context, arguments)
      else
        _context = parameter_context(context, parameters, arguments)

        body.interpret(_context)
      end
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance
      end
    end

    protected

    def curry(calling_context, arguments)
      parameters_for_curry = self.parameters[0...arguments.count]
      extra_parameters = self.parameters - parameters_for_curry

      _context = parameter_context(calling_context, parameters_for_curry, arguments)

      self.class.new(_context, self.keyword, extra_parameters, self.body)
    end

    def parameter_context(calling_context, parameters, arguments)
      parameters.zip(arguments).inject(calling_context.nested_context) do |memo, (parameter, argument)|
        _parameter = if parameter.is_a?(Rip::Nodes::Reference) && argument
          Rip::Nodes::Assignment.new(argument.location, parameter, argument)
        elsif parameter.is_a?(Rip::Nodes::Assignment) && argument
          Rip::Nodes::Assignment.new(argument.location, parameter.lhs, argument)
        elsif parameter.is_a?(Rip::Nodes::Assignment)
          parameter
        end

        _parameter.interpret(memo)

        memo
      end
    end
  end

  class RubyLambda < Rip::Core::Lambda
    def initialize(keyword, parameters, &body)
      super(nil, keyword, parameters, body)
    end

    def call(calling_context, arguments)
      _context = parameter_context(calling_context, parameters, arguments)
      body.call(self['@'], _context)
    end

    def self.binary_prototype_method(&body)
      new(Rip::Utilities::Keywords[:dash_rocket], [
        Rip::Nodes::Reference.new(nil, 'other')
      ]) do |this, context|
        body.call(this, context['other'])
      end
    end
  end
end
