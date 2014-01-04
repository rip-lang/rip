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

    define_class_instance do |class_instance|
      %w[
        + -
        * /
        %
      ].each do |property|
        class_instance['@'][property] = Rip::Core::RubyLambda.binary_prototype_method do |this, other|
          new(this.data.send(property, other.data))
        end
      end

      def class_instance.to_s
        'System.Integer'
      end
    end
  end
end
