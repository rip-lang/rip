module Rip::Nodes
  class Time < Base
    attr_reader :hour
    attr_reader :minute
    attr_reader :second
    attr_reader :sub_second
    attr_reader :offset

    def initialize(location, hour, minute, second, sub_second, offset)
      super(location)
      @hour = hour
      @minute = minute
      @second = second
      @sub_second = sub_second
      @offset = offset
    end

    def ==(other)
      super &&
        (hour == other.hour) &&
        (minute == other.minute) &&
        (second == other.second) &&
        (sub_second == other.sub_second) &&
        (offset == other.offset)
    end

    def interpret(context)
    end

    def resolve
      self
    end

    def to_debug(level = 0)
      [
        [ level, "#{super.last.last} (#{hour}:#{minute}:#{second}.#{sub_second}#{offset})" ]
      ]
    end

    class Offset
      attr_reader :sign
      attr_reader :hour
      attr_reader :minute

      def initialize(sign, hour, minute)
        @sign = sign
        @hour = hour
        @minute = minute
      end

      def ==(other)
        (sign == other.sign) &&
          (hour == other.hour) &&
          (minute == other.minute)
      end

      def to_s
        [
          sign,
          hour,
          minute
        ].join('')
      end
    end
  end
end
