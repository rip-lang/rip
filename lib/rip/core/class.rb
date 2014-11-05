module Rip::Core
  class Class < Rip::Core::Base
    attr_reader :ancestors

    def initialize(ancestors = [])
      super()

      parents = ancestors + [ Rip::Core::Object.class_instance ]
      @ancestors = parents.inject([ self ]) do |memo, parent|
        memo + [ parent ] + parent.ancestors
      end.uniq

      self['class'] = self.class.class_instance
      self['self'] = self
      self['@'] = Rip::Core::Prototype.new
    end

    def nested_context
      Rip::Compiler::Scope.new(self)
    end

    def self.class_instance
      return @class_instance if instance_variable_defined? :@class_instance

      @class_instance = Rip::Core::Object.new
      @class_instance['class'] = @class_instance

      @class_instance = new.tap do |reply|
        reply['class'] = reply

        def reply.to_s
          '#< System.Class >'
        end
      end
    end
  end
end
