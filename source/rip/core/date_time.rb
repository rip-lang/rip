module Rip::Core
  class DateTime < Rip::Core::Base
    attr_reader :date
    attr_reader :time

    def initialize(date, time)
      super()
      @date = date
      @time = time
    end
  end
end
