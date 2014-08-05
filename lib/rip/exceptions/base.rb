module Rip::Exceptions
  class Base < StandardError
    attr_reader :message
    attr_reader :location
    attr_reader :call_stack

    def initialize(message, location = nil, call_stack = [])
      @message = message
      @location = location
      @call_stack = call_stack
    end

    def dump
      [ inspect, *call_stack_lines ].join("\n")
    end

    def status_code
      self.class.status_code
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def to_s
      "(##{status_code}) #{message.inspect} @ #{location}"
    end

    def self.status_code(code = nil)
      if code.nil?
        @status_code
      else
        @status_code = code
      end
    end

    protected

    def call_stack_lines
      unless call_stack.count.zero?
        [ '', 'Call stack:' ] + call_stack.map { |line| "\t#{line}" }
      end
    end
  end
end
