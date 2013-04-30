module Rip::Nodes
  class Comment < Base
    attr_reader :text

    def initialize(location, text)
      super(location)
      @text = text
    end

    def ==(other)
      super &&
        (text == other.text)
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{text})" ]
      ]
    end
  end
end
