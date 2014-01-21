module Rip::Core
  class String < Rip::Core::Base
    attr_reader :characters

    def initialize(characters = [])
      super()

      @characters = characters

      self['class'] = self.class.class_instance
    end

    def to_s
      _characters = characters.map(&:to_s)
      "\"#{_characters.join('')}\""
    end

    define_class_instance do |class_instance|
      def class_instance.to_s
        'System.String'
      end
    end
  end
end
