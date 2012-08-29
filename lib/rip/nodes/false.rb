require 'rip/nodes'

module Rip::Nodes
  class False
    def self.evaluate
      false
    end
  end
end
