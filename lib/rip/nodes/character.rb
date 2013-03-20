module Rip::Nodes
  class Character < Base
    attr_reader :data

    def initialize(location, data)
      super(location)
      @data = data.to_sym
    end

    def ==(other)
      super &&
        (data == other.data)
    end
  end
end
