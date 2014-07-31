module Rip::Core
  class Character < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data.to_s

      self['class'] = self.class.class_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s_prep_body
      super + [ "data = `#{data}" ]
    end

    define_class_instance('character') do |class_instance|
      uppercase_overload = Rip::Core::NativeOverload.new([
      ]) do |context|
        new(context['@'].data.upcase)
      end
      class_instance['@']['uppercase'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ uppercase_overload ])

      lowercase_overload = Rip::Core::NativeOverload.new([
      ]) do |context|
        new(context['@'].data.downcase)
      end
      class_instance['@']['lowercase'] = Rip::Core::Lambda.new(Rip::Utilities::Scope.new, [ lowercase_overload ])

      def class_instance.to_s
        '#< System.Character >'
      end
    end
  end
end
