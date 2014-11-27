module Rip::Core
  class String < Rip::Core::Base
    attr_reader :characters
    alias :items :characters

    def initialize(characters = [])
      super()

      @characters = characters

      self['class'] = self.class.type_instance
    end

    def ==(other)
      (self['class'] == other['class']) &&
        (characters == other.characters)
    end

    def to_native
      characters.map(&:data).join('')
    end

    def to_s_prep_body
      _characters = characters.map(&:to_s).join(', ')
      super + [ "characters = \"#{_characters}\"" ]
    end

    def self.from_native(string)
      characters = string.split('').map do |character|
        Rip::Core::Character.new(character)
      end

      new(characters)
    end

    define_type_instance('string') do |type_instance|
      type_instance['@']['uppercase'] = Rip::Core::DelayedProperty.new do |_|
        uppercase_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          this = context['@']
          characters = this.characters.map do |character|
            character['uppercase'].call([])
          end
          new(characters)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ uppercase_overload ])
      end

      type_instance['@']['lowercase'] = Rip::Core::DelayedProperty.new do |_|
        lowercase_overload = Rip::Core::NativeOverload.new([
        ]) do |context|
          this = context['@']
          characters = this.characters.map do |character|
            character['lowercase'].call([])
          end
          new(characters)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Driver.global_context.nested_context, [ lowercase_overload ])
      end

      def type_instance.to_s
        '#< System.String >'
      end
    end
  end
end
