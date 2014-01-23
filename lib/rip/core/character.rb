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

    def to_s
      "`#{data}"
    end

    def inspect_prep_body
      super + [ "data = #{to_s}" ]
    end

    define_class_instance do |class_instance|
      class_instance['@']['uppercase'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        new(this.data.upcase)
      end

      class_instance['@']['lowercase'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        new(this.data.downcase)
      end

      def class_instance.to_s
        'System.Character'
      end
    end
  end
end
