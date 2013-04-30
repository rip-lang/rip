module Rip::Nodes
  class Map < List
    def initialize(location, key_value_pairs)
      super(location, key_value_pairs)
    end

    alias :key_value_pairs :items
  end
end
