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

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance
      end
    end
  end
end
