module Rip::Core
  class Type < Rip::Core::Base
    attr_reader :ancestors

    def initialize(ancestors = [])
      super()

      parents = ancestors + [ Rip::Core::Object.type_instance ]
      @ancestors = parents.inject([ self ]) do |memo, parent|
        memo + [ parent ] + parent.ancestors
      end.uniq

      self['type'] = self.class.type_instance
      self['self'] = self
      self['@'] = Rip::Core::Prototype.new
    end

    def nested_context(origin = nil)
      Rip::Compiler::Scope.new(self, origin)
    end

    def self.type_instance
      return @type_instance if instance_variable_defined? :@type_instance

      @type_instance = Rip::Core::Object.new
      @type_instance['type'] = @type_instance

      @type_instance = new.tap do |reply|
        reply['type'] = reply

        def reply.to_s
          '#< System.Type >'
        end
      end
    end
  end
end
