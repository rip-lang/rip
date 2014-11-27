module Rip::Core
  class Class < Rip::Core::Base
    attr_reader :ancestors

    def initialize(ancestors = [])
      super()

      parents = ancestors + [ Rip::Core::Object.type_instance ]
      @ancestors = parents.inject([ self ]) do |memo, parent|
        memo + [ parent ] + parent.ancestors
      end.uniq

      self['class'] = self.class.type_instance
      self['self'] = self
      self['@'] = Rip::Core::Prototype.new
    end

    def nested_context
      Rip::Compiler::Scope.new(self)
    end

    def self.type_instance
      return @type_instance if instance_variable_defined? :@type_instance

      @type_instance = Rip::Core::Object.new
      @type_instance['class'] = @type_instance

      @type_instance = new.tap do |reply|
        reply['class'] = reply

        def reply.to_s
          '#< System.Class >'
        end
      end
    end
  end
end
