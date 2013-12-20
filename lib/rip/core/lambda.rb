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
      _context = block_context(context, arguments)
      body.interpret(_context)
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance
      end
    end

    protected

    def block_context(calling_context, arguments)
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
      _context = block_context(calling_context, arguments)
      body.call(self['@'], _context)
    end
  end
end
