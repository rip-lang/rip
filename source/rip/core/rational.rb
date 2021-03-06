module Rip::Core
  class Rational < Rip::Core::Base
    attr_reader :data

    def initialize(numerator, denominator, sign = :+)
      super()

      @data = Rational(numerator, denominator) * (sign.to_sym == :+ ? 1 : -1)

      self['type'] = self.class.type_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ "numerator = #{data.numerator}, denominator = #{data.denominator}" ]
    end

    def self.from_native(rational)
      new(rational.numerator, rational.denominator)
    end

    def self.integer(integer)
      new(integer, 1)
    end

    define_type_instance('rational') do |type_instance|
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
            result = context['a'].data.send(property, context['b'].data)
            from_native(result)
          end

          Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ overload ])
        end
      end

      %w[
        < <=
        > >=
      ].each do |property|
        type_instance[property] = Rip::Core::DelayedProperty.new do |_|
          overload = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('a', type_instance),
            Rip::Core::Parameter.new('b', type_instance)
          ]) do |context|
            Rip::Core::Boolean.from_native(context['a'].data.send(property, context['b'].data))
          end

          Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ overload ])
        end
      end

      type_instance['@']['=='] = Rip::Core::DelayedProperty.new do |_|
        eequals_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('other', type_instance)
        ]) do |context|
          Rip::Core::Boolean.from_native(context['@'].data == context['other'].data)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ eequals_overload ])
      end

      type_instance['round'] = Rip::Core::DelayedProperty.new do |_|
        round_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('precision', type_instance),
          Rip::Core::Parameter.new('number', type_instance)
        ]) do |context|
          number = context['number'].data
          precision = context['precision'].data.round(0)
          from_native(number.round(precision))
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ round_overload ])
      end

      type_instance['round_up'] = Rip::Core::DelayedProperty.new do |_|
        ceiling_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('number', type_instance)
        ]) do |context|
          new(context['number'].data.ceil, 1)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ ceiling_overload ])
      end

      type_instance['round_down'] = Rip::Core::DelayedProperty.new do |_|
        floor_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('number', type_instance)
        ]) do |context|
          new(context['number'].data.floor, 1)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ floor_overload ])
      end

      type_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          this_data = context['@'].data
          native = this_data.denominator == 1 ? this_data.numerator.to_s : "(#{this_data.numerator} / #{this_data.denominator})"
          Rip::Core::String.from_native(native)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System.Rational >'
      end
    end
  end
end
