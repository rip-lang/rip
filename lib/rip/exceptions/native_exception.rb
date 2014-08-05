module Rip::Exceptions
  class NativeException < Base
    attr_reader :exception

    status_code 10

    def initialize(exception, location, call_stack = [])
      super('Unknown exception has occurred. Please open an issue report at github.com/rip-lang/rip/issues', location, call_stack)
      @exception = exception
    end

    def dump
      [ inspect, *call_stack_lines, *call_stack_native_lines ].join("\n")
    end

    protected

    def call_stack_native_lines
      [ '', 'Call stack (native):', exception.inspect, *exception.backtrace ].map { |line| "\t#{line}" }
    end
  end
end
