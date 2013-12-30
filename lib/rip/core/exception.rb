module Rip::Core
  class Exception < Rip::Core::Object
    attr_reader :message

    def initialize(message)
      super()
      @message = message
    end
  end
end
