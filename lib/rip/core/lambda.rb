module Rip::Core
  class Lambda < Rip::Core::Base
    attr_reader :context
    attr_reader :keyword
    attr_reader :parameters
    attr_reader :body

    def initialize(context, keyword, parameters, body)
      super()
      @context = context
      @keyword = keyword
      @parameters = parameters
      @body = body
    end
  end
end
