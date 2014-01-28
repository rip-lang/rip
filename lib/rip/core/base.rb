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
      reply = (properties[key] ||
        properties['class']['@'][key]).tap do |reply|
        if reply.is_a?(Rip::Core::Lambda)
          reply['@'] = self
        end
      end

      if reply.is_a?(Rip::Core::DynamicProperty)
        properties[key] = reply.block.call(self)
      else
        reply
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

    def symbols
      properties.keys
    end

    def self.define_class_instance(core_module_name = nil, &block)
      define_singleton_method :class_instance do
        return @class_instance if instance_variable_defined? :@class_instance

        @class_instance = if core_module_name
          load_path = Rip.root + 'core'
          Rip::Loaders::FileSystem.new(core_module_name, [ load_path ]).load
        else
          Rip::Core::Class.new.tap do |reply|
            reply['class'] = Rip::Core::Class.class_instance
          end
        end

        def @class_instance.inspect_prep_body
          [ to_s ]
        end

        block.call(@class_instance)

        @class_instance
      end
    end
  end
end
