require 'rip/nodes/nil'
require 'rip/transform'

module Rip
  class AST
    attr_reader :tree

    def initialize(parse_tree)
      parse = if parse_tree.empty?
        [Rip::Nodes::Nil]
      else
        parse_tree
      end
      @tree = Rip::Transform.new.apply parse
    end

    # TODO recurse tree
    def evaluate
      tree.each do |node|
        puts node.inspect
      end
    end
  end
end
