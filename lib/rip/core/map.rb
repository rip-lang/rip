module Rip::Core
  class Map < Rip::Core::Base
    attr_reader :pairs

    def initialize(pairs = [])
      super()

      @pairs = pairs

      self['class'] = self.class.type_instance
    end

    def to_s_prep_body
      _pairs = pairs.map(&:to_s).join(', ')
      super + [ "pairs = { #{_pairs} }" ]
    end

    define_type_instance do |type_instance|
      def type_instance.to_s
        '#< System.Map >'
      end
    end
  end
end
