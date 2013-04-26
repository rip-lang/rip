module Rip::Nodes
  class Try < Base
    attr_reader :attempt_body
    attr_reader :catch_blocks
    attr_reader :finally_block

    def initialize(location, attempt_body, catch_blocks, finally_block)
      super(location)
      @attempt_body = attempt_body
      @catch_blocks = catch_blocks
      @finally_block = finally_block
    end

    def ==(other)
      super &&
        (attempt_body == other.attempt_body) &&
        (catch_blocks == other.catch_blocks) &&
        (finally_block == other.finally_block)
    end
  end
end
