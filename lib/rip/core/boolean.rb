module Rip::Core
  class Boolean < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()
      @data = data
    end

    def ==(other)
      data == other.data
    end

    def self.true
      new(true)
    end

    def self.false
      new(false)
    end
  end
end
