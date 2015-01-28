module Rip::Core
  class Date < Rip::Core::Base
    attr_reader :year
    attr_reader :month
    attr_reader :day

    def initialize(year, month, day)
      super()
      @year = year
      @month = month
      @day = day
    end
  end
end
