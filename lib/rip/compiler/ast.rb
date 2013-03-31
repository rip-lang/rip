require 'parslet'

module Rip::Compiler
  class AST < Parslet::Transform
    attr_reader :origin

    def initialize(origin)
      @origin = origin
    end

    protected

    def location_for(slice)
      slice.line_and_column
    end
  end
end
