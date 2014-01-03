module Rip::Core
  class Class < Rip::Core::Base
    def initialize
      super

      self['class'] = self.class.class_instance
      self['@'] = Rip::Core::Prototype.new
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Object.new
      @class_instance['class'] = @class_instance

      @class_instance = new.tap do |reply|
        reply['class'] = reply

        def reply.to_s
          'System.Class'
        end

        def reply.inspect_prep_body
          [ to_s ]
        end
      end
    end
  end
end
