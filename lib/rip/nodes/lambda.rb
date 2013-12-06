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

    def interpret(context)
    end

    def to_debug(level = 0)
      parameters_debug_inner = parameters.inject([]) do |reply, parameter|
        reply + parameter.to_debug(level + 2)
      end

      parameters_debug = [ [ level + 1, 'parameters = [' ] ] +
        parameters_debug_inner +
        [ [ level + 1, ']' ] ]

      body_debug = [ [ level + 1, 'body = [' ] ] +
        body.to_debug(level + 2) +
        [ [ level + 1, ']' ] ]

      [
        [ level, "#{super.last.last} (#{keyword.to_debug})" ]
      ] + parameters_debug + body_debug
    end
  end
end
