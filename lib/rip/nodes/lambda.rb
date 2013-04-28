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

    def to_debug(level = 0)
      arguments_debug = arguments.inject([]) do |reply, argument|
        reply + argument.to_debug(level + 1)
      end

      [
        [ level, "#{super.last.last} #{keyword}" ]
      ] + arguments_debug + body.to_debug(level + 1)
    end
  end
end
