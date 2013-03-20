module Rip
  class Exception
    attr_reader :message
    attr_reader :location
    attr_reader :call_stack

    def initialize(message, location = nil, call_stack = [])
      @message = message
      @location = location
      @call_stack = call_stack
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def to_s
      "#{message.inspect} @ #{location}"
    end
  end
end
