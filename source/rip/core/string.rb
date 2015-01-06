module Rip::Core
  class String < Rip::Core::Base
    attr_reader :characters
    alias :items :characters

    def initialize(characters = [])
      super()

      @characters = characters

      self['type'] = self.class.type_instance
    end

    def ==(other)
      (self['type'] == other['type']) &&
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
      type_instance['+'] = Rip::Core::DelayedProperty.new do |_|
        plus_overload = Rip::Core::NativeOverload.new([
          Rip::Core::Parameter.new('a', type_instance),
          Rip::Core::Parameter.new('b', type_instance)
        ]) do |context|
          a = context['a']
          b = context['b']
          Rip::Core::String.new(a.characters + b.characters)
        end
        Rip::Core::Lambda.new(Rip::Compiler::Scope.new, [ plus_overload ])
      end

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
