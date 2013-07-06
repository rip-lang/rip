module Rip::Core
  class List < Rip::Core::Base
    attr_reader :items

    def initialize(items = [])
      super()
      @items = items
    end
  end
end
