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
      _key = key.to_s
      reply = get(_key) || (raise Rip::Exceptions::RuntimeException.new("Unknown property `#{key}`"))

      case reply
      when Rip::Core::DynamicProperty
        reply.resolve(_key, self)
      when Rip::Core::Lambda
        reply.bind(self)
      else
        reply
      end
    end

    def get(key)
      _key = key.to_s
      properties['class'].ancestors.inject(properties[_key]) do |memo, ancestor|
        memo || ancestor['@'][_key]
      end
    end

    def []=(key, value)
      properties[key.to_s] = value
    end

    def to_s
      to_s_prep.join(' ')
    end

    def to_s_prep
      to_s_prep_prefix +
        to_s_prep_body +
        to_s_prep_postfix
    end

    def to_s_prep_prefix
      [ '#<' ]
    end

    def to_s_prep_body
      [
        self['class'].to_s,
        [
          '[',
          property_names.sort.join(', '),
          ']'
        ].join(' ')
      ]
    end

    def to_s_prep_postfix
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

        block.call(@class_instance)

        @class_instance
      end
    end
  end
end
