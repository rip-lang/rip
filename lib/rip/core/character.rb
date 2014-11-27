module Rip::Core
  class Character < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data.to_s

      self['class'] = self.class.type_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ "data = `#{data}" ]
    end

    define_type_instance('character') do |type_instance|
      type_instance['@']['uppercase'] = Rip::Core::DelayedProperty.new do |_|
        uppercase_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          new(context['@'].data.upcase)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ uppercase_overload ])
      end

      type_instance['@']['lowercase'] = Rip::Core::DelayedProperty.new do |_|
        lowercase_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          new(context['@'].data.downcase)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ lowercase_overload ])
      end

      type_instance['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native("`#{context['@'].data}")
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System.Character >'
      end
    end
  end
end
