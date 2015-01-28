module Rip::Core
  class IO < Rip::Core::Base
    def initialize
      super()

      self['type'] = self.class.type_instance
    end

    define_type_instance('io') do |type_instance|
      {
        'out' => STDOUT,
        'error' => STDERR
      }.each do |name, std|
        type_instance[name] = Rip::Core::DelayedProperty.new do |_|
          overload_1 = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('message', Rip::Core::String.type_instance)
          ]) do |context|
            context['message'].tap do |reply|
              std.print(reply.to_native)
            end
          end

          overload_2 = Rip::Core::NativeOverload.new([
            Rip::Core::Parameter.new('object', Rip::Core::Object.type_instance)
          ]) do |context|
            context['self'].call(context, [ context['object']['to_string'].call(context, []) ])
          end

          Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ overload_1, overload_2 ])
        end
      end

      type_instance['in'] = Rip::Core::DelayedProperty.new do |_|
        overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          Rip::Core::String.from_native(STDIN.gets)
        end

        Rip::Core::Lambda.new(Rip::Compiler::Scope.global_context.nested_context, [ overload ])
      end

      def type_instance.to_s
        '#< System.IO >'
      end
    end
  end
end
