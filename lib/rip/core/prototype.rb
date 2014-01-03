module Rip::Core
  class Prototype < Rip::Core::Base
    def [](key)
      properties[key] ||
        (raise Rip::Exceptions::RuntimeException.new("Unknown property `#{key}`"))
    end

    def to_s
      (inspect_prep_prefix +
        Array('@') +
        inspect_prep_postfix).join(' ')
    end

    def inspect_prep_body
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
