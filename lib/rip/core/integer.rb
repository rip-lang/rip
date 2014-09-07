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

    def to_s_prep_body
      super + [ "data = #{data}" ]
    end

    define_class_instance('integer') do |class_instance|
      %w[
        + -
        * /
        %
      ].each do |property|
        class_instance[property] = Rip::Core::DelayedProperty.new do |_|
          overload = Rip::Core::NativeOverload.new([
            Rip::Nodes::Parameter.new(nil, 'a'),
            Rip::Nodes::Parameter.new(nil, 'b')
          ]) do |context|
            new(context['a'].data.send(property, context['b'].data))
          end

          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ overload ])
        end
      end

      class_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native(context['@'].data.to_s)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def class_instance.to_s
        '#< System.Integer >'
      end
    end
  end
end
