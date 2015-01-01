module Rip::Core
  class RegularExpression < Rip::Core::Base
    attr_reader :pattern

    def initialize(pattern)
      super()
      @pattern = pattern
    end
  end
end
