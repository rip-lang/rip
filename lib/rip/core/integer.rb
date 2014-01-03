module Rip::Core
  class Integer < Rip::Core::Base
    attr_reader :data

    def initialize(data, sign = :+)
      super()

      @data = data.to_i * (sign.to_sym == :+ ? 1 : -1)

      self['class'] = self.class.class_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s
      data.to_s
    end

    def inspect_prep_body
      super + [ "data = #{data}" ]
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance

        %w[
          + -
          * /
          %
        ].each do |property|
          reply['@'][property] = Rip::Core::RubyLambda.binary_prototype_method do |this, other|
            new(this.data.send(property, other.data))
          end
        end

        def reply.to_s
          'System.Integer'
        end

        def reply.inspect_prep_body
          [ to_s ]
        end
      end
    end
  end
end
