module Rip::Nodes
  class Rescue < Base
    attr_reader :body

    def initialize(location, parameter, body)
      super(location)
      @parameter = parameter
      @body = body
    end

    def ==(other)
      super &&
        (parameter == other.parameter) &&
        (body == other.body)
    end
  end
end
