module Rip::Core
  class Boolean < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data

      self['type'] = self.class.type_instance
    end

    def ==(other)
      data == other.data
    end

    def to_native
      data
    end

    def to_s_prep_body
      super + [ data.to_s ]
    end

    def self.true
      type_instance['true']
    end

    def self.false
      type_instance['false']
    end

    def self.from_native(boolean)
      boolean ? Rip::Core::Boolean.true : Rip::Core::Boolean.false
    end

    define_type_instance do |type_instance|
      type_instance['true'] = Rip::Core::DynamicProperty.new { |_| new(true) }
      type_instance['false'] = Rip::Core::DynamicProperty.new { |_| new(false) }

      type_instance['@']['=='] = Rip::Core::DelayedProperty.new do |_|
        eequals_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('other', type_instance)
        ]) do |context|
          if context['@'].data == context['other'].data
            Rip::Core::Boolean.true
          else
            Rip::Core::Boolean.false
          end
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ eequals_overload ])
      end

      type_instance['@']['to_boolean'] = Rip::Core::DelayedProperty.new do |_|
        to_boolean_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          context['@']
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_boolean_overload ])
      end

      type_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native(context['@'].data.to_s)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System.Boolean >'
      end
    end
  end
end
