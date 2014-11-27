module Rip::Core
  class System < Rip::Core::Base
    define_type_instance do |type_instance|
      type_instance['require'] = Rip::Core::DelayedProperty.new do |_|
        overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('module_name', Rip::Core::String.type_instance)
        ]) do |context|
          module_name = context['module_name'].characters.map(&:data).join

          Rip::Loaders::FileSystem.load_module(module_name, context.origin).tap do |reply|
            raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`", context.origin) if reply.nil?
          end
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ overload ])
      end

      type_instance['Boolean']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Boolean.type_instance }
      type_instance['Character']         = Rip::Core::DelayedProperty.new { |_| Rip::Core::Character.type_instance }
      # type_instance['Class']             = Rip::Core::DelayedProperty.new { |_| Rip::Core::Class.type_instance }
      # type_instance['Date']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::Date.type_instance }
      # type_instance['DateTime']          = Rip::Core::DelayedProperty.new { |_| Rip::Core::DateTime.type_instance }
      # type_instance['Decimal']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Decimal.type_instance }
      # type_instance['Exception']         = Rip::Core::DelayedProperty.new { |_| Rip::Core::Exception.type_instance }
      type_instance['Integer']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Integer.type_instance }
      # type_instance['KeyValue']          = Rip::Core::DelayedProperty.new { |_| Rip::Core::KeyValue.type_instance }
      # type_instance['Lambda']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::Lambda.type_instance }
      type_instance['List']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::List.type_instance }
      # type_instance['Map']               = Rip::Core::DelayedProperty.new { |_| Rip::Core::Map.type_instance }
      # type_instance['Object']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::Object.type_instance }
      # type_instance['Range']             = Rip::Core::DelayedProperty.new { |_| Rip::Core::Range.type_instance }
      # type_instance['RegularExpression'] = Rip::Core::DelayedProperty.new { |_| Rip::Core::RegularExpression.type_instance }
      type_instance['String']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::String.type_instance }
      # type_instance['Time']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::Time.type_instance }

      type_instance['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native('System')
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def type_instance.to_s
        '#< System >'
      end
    end
  end
end
