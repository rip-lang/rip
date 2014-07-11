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
      class_instance['@']['uppercase'] = Rip::Core::NativeLambda.new([]) do |this, context|
        new(this.data.upcase)
      end

      class_instance['@']['lowercase'] = Rip::Core::NativeLambda.new([]) do |this, context|
        new(this.data.downcase)
      end

      def class_instance.to_s
        '#< System.Character >'
      end
    end
  end
end
