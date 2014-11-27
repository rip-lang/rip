module Rip::Core
  class Integer < Rip::Core::Base
    attr_reader :data

    def initialize(data, sign = :+)
      super()

      @data = data.to_i * (sign.to_sym == :+ ? 1 : -1)

      self['type'] = self.class.type_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ "data = #{data}" ]
    end

    define_type_instance('integer') do |type_instance|
      %w[
        + -
        * /
        %
      ].each do |property|
        type_instance[property] = Rip::Core::DelayedProperty.new do |_|
          overload = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('a', type_instance),
            Rip::Core::Parameter.new('b', type_instance)
          ]) do |context|
            new(context['a'].data.send(property, context['b'].data))
          end

          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ overload ])
        end
      end

      type_instance['@']['=='] = Rip::Core::DelayedProperty.new do |_|
        eequals_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('other', type_instance)
        ]) do |context|
          Rip::Core::Boolean.from_native(context['@'].data == context['other'].data)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ eequals_overload ])
      end

      type_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native(context['@'].data.to_s)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System.Integer >'
      end
    end
  end
end
