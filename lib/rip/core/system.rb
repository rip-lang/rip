module Rip::Core
  class System < Rip::Core::Base
    define_class_instance do |class_instance|
      class_instance['require'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], [
        Rip::Nodes::Reference.new(nil, 'module_name')
      ]) do |this, context|
        module_name = context['module_name'].characters.map(&:data).join

        Rip::Loaders::FileSystem.load_module(module_name).tap do |reply|
          raise Rip::Exceptions::LoadException.new("Cannot load module: `#{module_name}`") if reply.nil?
        end
      end

      def class_instance.to_s
        'System'
      end
    end
  end
end
