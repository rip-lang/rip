module Rip::Utilities
  class TemporaryBlock
    attr_reader :location
    attr_reader :body
    attr_reader :argument

    def initialize(location, body, argument = nil)
      @location = location
      @body = body
      @argument = argument
    end
  end
end
