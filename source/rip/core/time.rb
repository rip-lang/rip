module Rip::Core
  class Time < Rip::Core::Base
    attr_reader :hour
    attr_reader :minute
    attr_reader :second
    attr_reader :offset

    # second is a decimal
    def initialize(hour, minute, second, offset)
      super()
      @hour = hour
      @minute = minute
      @second = second
      @offset = offset
    end
  end
end
