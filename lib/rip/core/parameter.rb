module Rip::Core
  class Parameter < Rip::Core::Base
    attr_reader :name
    attr_reader :type

    def initialize(name, type)
      super()

      @name = name
      @type = type
    end

    def ==(other)
      (name == other.name) &&
        (type == other.type)
    end

    def bind(context, argument)
      unless matches?(argument['class'])
        raise Rip::Exceptions::CompilerException.new("Parameter type mis-match: expected `#{name}` to be a `#{type}`, but was a `#{argument['class']}`", location)
      end

      context.tap do |reply|
        reply[name] = argument
      end
    end

    def matches?(argument_type)
      argument_type.ancestors.include?(type) ||
        special_case_for_class?(argument_type) ||
        special_case_for_lambda?(argument_type)
    end

    protected

    def special_case_for_class?(argument_type)
      (argument_type == Rip::Core::Class.class_instance) &&
        (type == Rip::Core::Object.class_instance)
    end

    def special_case_for_lambda?(argument_type)
      (argument_type == Rip::Core::Lambda.class_instance) &&
        (type == Rip::Core::Object.class_instance)
    end
  end
end
