require 'rip/nodes'

module Rip::Nodes
  class Comment
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def ==(other)
      text == other.text
    end

    def evaluate
    end
  end
end
