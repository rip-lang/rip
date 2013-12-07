module Rip::Core
  class Character < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data.to_s

      self['class'] = self.class.class_instance
    end

    def ==(other)
      data == other.data
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance
      end
    end
  end
end
