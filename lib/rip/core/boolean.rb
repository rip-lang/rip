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
      new(true)
    end

    def self.false
      new(false)
    end

    define_class_instance do |class_instance|
      class_instance['@']['to_boolean'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        this
      end

      def class_instance.to_s
        '#< System.Boolean >'
      end
    end
  end
end
