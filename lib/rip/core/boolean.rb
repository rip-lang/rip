module Rip::Core
  class Boolean < Rip::Core::Base
    attr_reader :data

    def initialize(data)
      super()

      @data = data

      self['class'] = self.class.class_instance
    end

    def ==(other)
      data == other.data
    end

    def to_s
      data.to_s
    end

    def inspect_prep_body
      super + [ to_s ]
    end

    def self.true
      new(true)
    end

    def self.false
      new(false)
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Class.new.tap do |reply|
        reply['class'] = Rip::Core::Class.class_instance

        def reply.to_s
          'System.Boolean'
        end

        def reply.inspect_prep_body
          [ to_s ]
        end
      end
    end
  end
end
