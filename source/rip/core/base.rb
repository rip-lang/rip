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

      reply = properties['type'].ancestors.inject(properties[_key]) do |memo, ancestor|
        memo || ancestor['@'][_key]
      end

      finalize_property(_key, reply)
    end

    def []=(key, value)
      properties[key.to_s] = value
    end

    alias :full_inspect :inspect
    def inspect
      _instance_variables = instance_variables.map do |ivar|
        ivar_value = if ivar == :@properties
          instance_variable_get(ivar).keys.sort
        else
          instance_variable_get(ivar).inspect
        end

        "#{ivar}=#{ivar_value}"
      end

      space = ' ' unless _instance_variables.count.zero?

      "#<#{self.class}:#{object_id}#{space}#{_instance_variables.join(', ')}>"
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
        self['type'].to_s,
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
      self['type']['@'].properties.merge(properties).keys.uniq
    end

    def symbols
      properties.keys
    end

    def self.define_type_instance(core_module_name = nil, &block)
      define_singleton_method :type_instance do
        return @type_instance if instance_variable_defined? :@type_instance

        @type_instance = if core_module_name
          load_path = Rip.root + 'core'
          Rip::Loaders::FileSystem.new(core_module_name, [ load_path ]).load
        else
          Rip::Core::Type.new.tap do |reply|
            reply['type'] = Rip::Core::Type.type_instance
          end
        end

        block.call(@type_instance)

        @type_instance
      end
    end

    protected

    def finalize_property(key, property)
      case property
      when NilClass
        location = key.location if key.respond_to?(:location)
        raise Rip::Exceptions::RuntimeException.new("Unknown property `#{key}`", location)
      when Rip::Core::DynamicProperty
        property.resolve(key, self)
      when Rip::Core::DelayedProperty
        reply = property.resolve(key, self)
        reply.is_a?(Rip::Core::Lambda) ? finalize_property(key, reply) : reply
      when Rip::Core::Lambda
        property.bind(self)
      else
        property
      end
    end
  end
end
