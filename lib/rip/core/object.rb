module Rip::Core
  class Object < Rip::Core::Base
    def initialize
      super

      self['class'] = self.class.class_instance
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Base.new
      @class_instance['class'] = @class_instance

      def @class_instance.ancestors
        []
      end

      @class_instance = new.tap do |reply|
        reply['@'] = Rip::Core::Prototype.new

        reply['@']['to_boolean'] = Rip::Core::DelayedProperty.new do |_|
          to_boolean_overload = Rip::Core::NativeOverload.new([
          ]) do |context|
            Rip::Core::Boolean.true
          end
          Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ to_boolean_overload ])
        end

        reply['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
          to_string_overload = Rip::Core::NativeOverload.new([
          ]) do |context|
            Rip::Core::String.from_native(context['@'].to_s)
          end
          Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ to_string_overload ])
        end

        def reply.ancestors
          [ self ]
        end

        def reply.to_s
          '#< System.Object >'
        end
      end
    end
  end
end
