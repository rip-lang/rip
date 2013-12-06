module Rip::Core
  class Character < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()
      @data = data.to_s
    end

    def ==(other)
      data == other.data
    end
  end
end
