module Rip::Nodes
  class Assignment < Base
    attr_reader :reference
    attr_reader :value

    def initialize(location, reference, value)
      super(location)
      @reference = reference
      @value = value
    end
  end
end
