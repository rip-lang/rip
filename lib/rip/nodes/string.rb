require 'rip/nodes'
require 'rip/nodes/list'

module Rip::Nodes
  class String < List
    def initialize(phrase)
      super *phrase.to_str.split('').map(&:to_sym)
    end
  end
end
