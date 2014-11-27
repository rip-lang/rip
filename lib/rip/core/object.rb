module Rip::Core
  class Object < Rip::Core::Base
    def initialize
      super

      self['type'] = self.class.type_instance
    end

    def self.type_instance
      return @type_instance if instance_variable_defined? :@type_instance

      @type_instance = Rip::Core::Base.new
      @type_instance['type'] = @type_instance

      def @type_instance.ancestors
        []
      end

      @type_instance = new.tap do |reply|
        reply['@'] = Rip::Core::Prototype.new

        reply['@']['=='] = Rip::Core::DelayedProperty.new do |_|
          eequals_overload = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('other', reply)
          ]) do |context|
            Rip::Core::Boolean.from_native(context['@'].properties == context['other'].properties)
          end
          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ eequals_overload ])
        end

        reply['@']['==='] = Rip::Core::DelayedProperty.new do |_|
          eeequals_overload = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('other', reply)
          ]) do |context|
            context['@']['=='].call([ context['other'] ])
          end
          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ eeequals_overload ])
        end

        reply['@']['to_boolean'] = Rip::Core::DelayedProperty.new do |_|
          to_boolean_overload = Rip::Core::NativeOverload.new([
          ]) do |context|
            Rip::Core::Boolean.true
          end
          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_boolean_overload ])
        end

        reply['@']['to_string'] = Rip::Core::DelayedProperty.new do |_|
          to_string_overload = Rip::Core::NativeOverload.new([
          ]) do |context|
            Rip::Core::String.from_native(context['@'].to_s)
          end
          Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ to_string_overload ])
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
