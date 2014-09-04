module Rip::Core
  class DynamicProperty
    attr_reader :block

    def initialize(memoizable = true, &block)
      @memoizable = memoizable
      @block = block
    end

    def resolve(key, receiver)
      block.call(receiver).tap do |reply|
        receiver.properties[key] = reply if @memoizable
      end
    end
  end
end
