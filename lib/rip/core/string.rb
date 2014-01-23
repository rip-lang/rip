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
      class_instance['@']['uppercase'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        characters = this.characters.map do |character|
          character['uppercase'].call(context, [])
        end
        new(characters)
      end

      class_instance['@']['lowercase'] = Rip::Core::RubyLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        characters = this.characters.map do |character|
          character['lowercase'].call(context, [])
        end
        new(characters)
      end

      def class_instance.to_s
        'System.String'
      end
    end
  end
end
