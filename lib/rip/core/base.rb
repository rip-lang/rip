module Rip::Core
  class Base
    attr_reader :properties

    def initialize
      @properties = {}
    end

    def ==(other)
      properties == other.properties
    end

    def [](key)
      (properties[key] ||
        properties['class']['@'][key]).tap do |reply|
        if reply.is_a?(Rip::Core::Lambda)
          reply['@'] = self
        end
      end
    end

    def []=(key, value)
      properties[key] = value
    end

    def to_s
      inspect
    end

    def inspect
      inspect_prep.join(' ')
    end

    def inspect_prep
      inspect_prep_prefix +
        inspect_prep_body +
        inspect_prep_postfix
    end

    def inspect_prep_prefix
      [ '#<' ]
    end

    def inspect_prep_body
      [
        self['class'].to_s,
        [
          '[',
          property_names.sort.join(', '),
          ']'
        ].join(' ')
      ]
    end

    def inspect_prep_postfix
      [ '>' ]
    end

    def property_names
      self['class']['@'].properties.merge(properties).keys.uniq
    end
  end
end
