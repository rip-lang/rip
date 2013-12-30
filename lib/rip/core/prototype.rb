module Rip::Core
  class Prototype < Rip::Core::Base
    def [](key)
      properties[key] ||
        (raise Rip::Exceptions::RuntimeException.new("Unknown property `#{key}`"))
    end
  end
end
