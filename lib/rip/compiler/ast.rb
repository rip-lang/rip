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

    rule(:sign => simple(:sign), :integer => simple(:integer)) do |locals|
      sign = locals[:sign]
      location = location_for(locals[:origin], sign)
      Rip::Nodes::Integer.new(location, locals[:integer], sign)
    end

    rule(:sign => simple(:sign), :decimal => simple(:decimal)) do |locals|
      sign = locals[:sign]
      location = location_for(locals[:origin], sign)
      Rip::Nodes::Decimal.new(location, locals[:decimal], sign)
    end

    rule(:character => simple(:character)) do |locals|
      character = locals[:character]
      location = location_for(locals[:origin], character)
      Rip::Nodes::Character.new(location, character)
    end

    rule(:string => sequence(:characters)) do |locals|
      location = locals[:characters].first.location
      Rip::Nodes::String.new(location, locals[:characters])
    end
  end
end
