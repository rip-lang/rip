module Rip::Core
  class Class < Rip::Core::Base
    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = new.tap do |reply|
        reply['class'] = reply
      end
    end
  end
end
