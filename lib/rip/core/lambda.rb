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

    def inspect_prep_body
      super + [
        [
          "keyword = #{keyword.keyword}",
          "arity = #{arity}"
        ].join(', ')
      ]
    end

    def arity
      if required_parameters.count < parameters.count
        required_parameters.count..parameters.count
      else
        parameters.count
      end
    end

    def call(arguments, &block)
      _context = context.nested_context

      bound_parameters = []

      parameters.zip(arguments).each_with_index do |(parameter, argument), index|
        if bound_parameters.count == index
          bound_parameter = parameter.bind(_context, argument)
          bound_parameters << bound_parameter if bound_parameter
        end
      end

      remaining_parameters = parameters[bound_parameters.count..-1]

      bound_parameters.each do |parameter|
        parameter.inject(_context)
      end

      if remaining_parameters.any?
        curry(_context, remaining_parameters)
      elsif block_given?
        block.call(_context)
      else
        body.interpret(_context)
      end
    end

    define_class_instance do |class_instance|
      def class_instance.to_s
        'System.Lambda'
      end
    end

    protected

    def curry(bound_context, remaining_parameters)
      self.class.new(bound_context, keyword, remaining_parameters, body)
    end

    def required_parameters
      parameters.reject(&:default_expression)
    end
  end

  class RubyLambda < Rip::Core::Lambda
    def initialize(keyword, parameters, &body)
      super(Rip::Utilities::Scope.new, keyword, parameters, body)
    end

    def call(arguments)
      super(arguments) do |_context|
        body.call(self['@'], _context)
      end
    end

    def self.binary_prototype_method(&body)
      new(Rip::Utilities::Keywords[:dash_rocket], [
        Rip::Nodes::Parameter.new(nil, 'other')
      ]) do |this, context|
        body.call(this, context['other'])
      end
    end
  end

  class DynamicProperty
    attr_reader :block

    def initialize(&block)
      @block = block
    end
  end
end
