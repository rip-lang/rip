module Rip::Nodes
  class String < List
    def initialize(location, characters)
      super(location, characters)
    end

    alias :characters :items

    def to_debug(level = 0)
      characters_debug = characters.map(&:data).join('')

      [
        [ level, "#{self.class.short_name}@#{location.to_debug} (#{characters_debug})" ]
      ]
    end
  end
end
