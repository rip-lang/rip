module Rip::Core
  class Map < Rip::Core::Base
    attr_reader :pairs

    def initialize(pairs = [])
      super()
      @pairs = pairs
    end
  end
end
