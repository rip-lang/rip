module Rip::Nodes
  class Lambda < Base
    attr_reader :keyword
    attr_reader :parameters
    attr_reader :body

    def initialize(location, keyword, parameters, body)
      super(location)
      @keyword = keyword
      @parameters = parameters
      @body = body
    end

    def ==(other)
      super &&
        (keyword == other.keyword) &&
        (parameters == other.parameters) &&
        (body == other.body)
    end
  end
end
