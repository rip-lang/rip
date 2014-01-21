module Rip::Core
  class Map < Rip::Core::Base
    attr_reader :pairs

    def initialize(pairs = [])
      super()

      @pairs = pairs

      self['class'] = self.class.class_instance
    end

    def to_s
      _pairs = pairs.map(&:to_s)
      "{#{_pairs.join(', ')}}"
    end

    define_class_instance do |class_instance|
      def class_instance.to_s
        'System.Map'
      end
    end
  end
end
