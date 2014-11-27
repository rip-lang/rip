module Rip::Core
  class System < Rip::Core::Base
    define_class_instance do |class_instance|
      class_instance['require'] = Rip::Core::DelayedProperty.new do |_|
        overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('module_name', Rip::Core::String.class_instance)
        ]) do |context|
          module_name = context['module_name'].characters.map(&:data).join

          Rip::Loaders::FileSystem.load_module(module_name, context.origin).tap do |reply|
            raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`", context.origin) if reply.nil?
          end
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ overload ])
      end

      class_instance['Boolean']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Boolean.class_instance }
      class_instance['Character']         = Rip::Core::DelayedProperty.new { |_| Rip::Core::Character.class_instance }
      # class_instance['Class']             = Rip::Core::DelayedProperty.new { |_| Rip::Core::Class.class_instance }
      # class_instance['Date']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::Date.class_instance }
      # class_instance['DateTime']          = Rip::Core::DelayedProperty.new { |_| Rip::Core::DateTime.class_instance }
      # class_instance['Decimal']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Decimal.class_instance }
      # class_instance['Exception']         = Rip::Core::DelayedProperty.new { |_| Rip::Core::Exception.class_instance }
      class_instance['Integer']           = Rip::Core::DelayedProperty.new { |_| Rip::Core::Integer.class_instance }
      # class_instance['KeyValue']          = Rip::Core::DelayedProperty.new { |_| Rip::Core::KeyValue.class_instance }
      # class_instance['Lambda']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::Lambda.class_instance }
      class_instance['List']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::List.class_instance }
      # class_instance['Map']               = Rip::Core::DelayedProperty.new { |_| Rip::Core::Map.class_instance }
      # class_instance['Object']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::Object.class_instance }
      # class_instance['Range']             = Rip::Core::DelayedProperty.new { |_| Rip::Core::Range.class_instance }
      # class_instance['RegularExpression'] = Rip::Core::DelayedProperty.new { |_| Rip::Core::RegularExpression.class_instance }
      class_instance['String']            = Rip::Core::DelayedProperty.new { |_| Rip::Core::String.class_instance }
      # class_instance['Time']              = Rip::Core::DelayedProperty.new { |_| Rip::Core::Time.class_instance }

      class_instance['to_string'] = Rip::Core::DelayedProperty.new do |_|
        to_string_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native('System')
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
      end

      def class_instance.to_s
        '#< System >'
      end
    end
  end
end
