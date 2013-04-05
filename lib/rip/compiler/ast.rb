require 'parslet'

module Rip::Compiler
  class AST < Parslet::Transform
    attr_reader :origin

    def initialize(origin = nil, &block)
      @origin = origin
      super(&block)
    end

    def apply(tree, context = nil)
      _context = context ? context : {}
      super(tree, _context.merge(:origin => origin))
    end

    def self.location_for(origin, slice)
      Rip::Utilities::Location.new(origin, slice.offset, *slice.line_and_column)
    end

    rule(:comment => simple(:comment)) do |locals|
      comment = locals[:comment]
      location = location_for(locals[:origin], comment)
      Rip::Nodes::Comment.new(location, comment)
    end

    rule(:reference => simple(:reference)) do |locals|
      reference = locals[:reference]
      location = location_for(locals[:origin], reference)
      Rip::Nodes::Reference.new(location, reference)
    end
  end
end
