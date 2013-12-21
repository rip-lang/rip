module Rip::Core
  class Integer < Rip::Core::Base
    attr_reader :data
    attr_reader :sign

    def initialize(data, sign = :+)
      super()

      @data = data
      @sign = sign.to_sym

      self['class'] = self.class.class_instance
    end

    def ==(other)
      (data == other.data) &&
        (sign == other.sign)
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance

        reply['@']['+'] = Rip::Core::RubyLambda.binary_prototype_method do |this, other|
          new(this.data + other.data)
        end
      end
    end
  end
end
