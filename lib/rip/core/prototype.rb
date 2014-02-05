module Rip::Core
  class Prototype < Rip::Core::Base
    def [](key)
      properties[key]
    end

    def to_s_prep_body
      [
        '@',
        [
          '[',
          property_names.sort.join(', '),
          ']'
        ].reject(&:empty?).join(' ')
      ]
    end

    def property_names
      properties.keys
    end
  end
end
