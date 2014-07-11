module Rip::Core
  class String < Rip::Core::Base
    attr_reader :characters
    alias :items :characters

    def initialize(characters = [])
      super()

      @characters = characters

      self['class'] = self.class.class_instance
    end

    def ==(other)
      (self['class'] == other['class']) &&
        (characters == other.characters)
    end

    def to_s_prep_body
      _characters = characters.map(&:to_s).join(', ')
      super + [ "characters = \"#{_characters}\"" ]
    end

    define_class_instance('string') do |class_instance|
      class_instance['@']['uppercase'] = Rip::Core::NativeLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        characters = this.characters.map do |character|
          character['uppercase'].call([])
        end
        new(characters)
      end

      class_instance['@']['lowercase'] = Rip::Core::NativeLambda.new(Rip::Utilities::Keywords[:dash_rocket], []) do |this, context|
        characters = this.characters.map do |character|
          character['lowercase'].call([])
        end
        new(characters)
      end

      def class_instance.to_s
        '#< System.String >'
      end
    end
  end
end
