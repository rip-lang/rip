module Rip::Nodes
  class BlockBody < Base
    attr_reader :statements

    def initialize(location, statements)
      super(location)
      @statements = statements
    end

    def ==(other)
      super &&
        (statements == other.statements)
    end
  end
end
