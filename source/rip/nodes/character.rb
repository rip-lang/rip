module Rip::Nodes
  class Character < Base
    attr_reader :data

    def initialize(location, data)
      super(location)
      @data = data.to_s
    end

    def ==(other)
      super &&
        (data == other.data)
    end

    def interpret(context)
      Rip::Core::Character.new(data)
    end

    def resolve
      self
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{data})" ]
      ]
    end
  end
end
