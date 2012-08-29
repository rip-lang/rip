require 'rip/nodes'

module Rip::Nodes
  class True
    def self.evaluate
      true
    end
  end
end
