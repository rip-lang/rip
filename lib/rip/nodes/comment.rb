module Rip::Nodes
  class Comment < Base
    attr_reader :text

    def initialize(location, text)
      super(location)
      @text = text
    end
  end
end
