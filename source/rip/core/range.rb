module Rip::Core
  class Range < Rip::Core::Base
    attr_reader :start
    attr_reader :end
    attr_reader :exclusivity

    def initialize(location, start, ending, exclusivity = false)
      super()
      @start = start
      @end = ending
      @exclusivity = exclusivity
    end
  end
end
