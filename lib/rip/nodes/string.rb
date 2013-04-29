module Rip::Nodes
  class String < List
    def initialize(location, characters)
      super(location, characters)
    end

    alias :characters :items

    def to_debug(level = 0)
      characters_debug = characters.map(&:data).join('')

      [
        [ level, "#{super.last.last} (#{characters_debug})" ]
      ]
    end
  end
end
