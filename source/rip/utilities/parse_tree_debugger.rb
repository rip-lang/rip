module Rip::Utilities
  module ParseTreeDebugger
    def self.to_debug(tree, level = 0)
      [
        [ level, tree.inspect ]
      ]
    end
  end
end
