module Rip::Core
  class String < Rip::Core::Base
    attr_reader :characters

    def initialize(characters = [])
      super()
      @characters = characters
    end
  end
end
