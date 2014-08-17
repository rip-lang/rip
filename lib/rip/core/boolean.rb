module Rip::Core
  class Boolean < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data

      self['class'] = self.class.class_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ data.to_s ]
    end

    def self.true
      class_instance['true']
    end

    def self.false
      class_instance['false']
    end

    define_class_instance do |class_instance|
      class_instance['true'] = new(true)
      class_instance['false'] = new(false)

      to_boolean_overload = Rip::Core::NativeOverload.new([
      ]) do |context|
        context['@']
      end
      class_instance['@']['to_boolean'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ to_boolean_overload ])

      to_string_overload = Rip::Core::NativeOverload.new([
      ]) do |context|
        Rip::Core::String.from_native(context['@'].data.to_s)
      end
      class_instance['@']['to_string'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ to_string_overload ])

      def class_instance.to_s
        '#< System.Boolean >'
      end
    end
  end
end
