module Rip::Core
  class System < Rip::Core::Base
    def self.class_property(property_name)
      system_node = Rip::Nodes::Reference.new(nil, 'System')
      Rip::Nodes::Property.new(nil, system_node, property_name)
    end

    define_class_instance do |class_instance|
      overload = Rip::Core::NativeOverload.new([
        Rip::Nodes::Parameter.new(nil, 'module_name')
      ]) do |context|
        module_name = context['module_name'].characters.map(&:data).join

        Rip::Loaders::FileSystem.load_module(module_name, context.origin).tap do |reply|
          raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`") if reply.nil?
        end
      end
      class_instance['require'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ overload ])

      class_instance['Boolean']           = Rip::Core::Boolean.class_instance
      class_instance['Character']         = Rip::Core::Character.class_instance
      # class_instance['Class']             = Rip::Core::Class.class_instance
      # class_instance['Date']              = Rip::Core::Date.class_instance
      # class_instance['DateTime']          = Rip::Core::DateTime.class_instance
      # class_instance['Decimal']           = Rip::Core::Decimal.class_instance
      # class_instance['Exception']         = Rip::Core::Exception.class_instance
      class_instance['Integer']           = Rip::Core::Integer.class_instance
      # class_instance['KeyValue']          = Rip::Core::KeyValue.class_instance
      # class_instance['Lambda']            = Rip::Core::Lambda.class_instance
      class_instance['List']              = Rip::Core::List.class_instance
      # class_instance['Map']               = Rip::Core::Map.class_instance
      # class_instance['Object']            = Rip::Core::Object.class_instance
      # class_instance['Range']             = Rip::Core::Range.class_instance
      # class_instance['RegularExpression'] = Rip::Core::RegularExpression.class_instance
      class_instance['String']            = Rip::Core::String.class_instance
      # class_instance['Time']              = Rip::Core::Time.class_instance

      def class_instance.to_s
        '#< System >'
      end
    end
  end
end
