module Rip::Core
  class Prototype < Rip::Core::Base
    def [](key)
      reply = properties[key]

      if reply.class == Rip::Core::DelayedProperty
        reply.resolve(key, self)
      else
        reply
      end
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
