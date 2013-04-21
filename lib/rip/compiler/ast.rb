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

    def self.block_body(origin, slice, body)
      location = location_for(origin, slice)
      Rip::Nodes::BlockBody.new(location, body)
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

    rule(:regex => sequence(:pattern)) do |locals|
      location = location_for(locals[:origin], locals[:pattern].first)
      Rip::Nodes::RegularExpression.new(location, locals[:pattern].join(''))
    end

    rule(:key => simple(:key), :value => simple(:value)) do |locals|
      location = locals[:key].location
      Rip::Nodes::KeyValue.new(location, locals[:key], locals[:value])
    end

    rule(:key_value_pair => simple(:key_value_pair)) do |locals|
      locals[:key_value_pair]
    end

    rule(:start => simple(:start), :end => simple(:end), :exclusivity => simple(:exclusivity)) do |locals|
      location = locals[:start].location
      Rip::Nodes::Range.new(location, locals[:start], locals[:end], !locals[:exclusivity].nil?)
    end

    rule(:range => simple(:range)) do |locals|
      locals[:range]
    end

    rule(:callable => simple(:callable), :location => simple(:location), :arguments => sequence(:arguments)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Invocation.new(location, locals[:callable], locals[:arguments])
    end

    rule(:invocation => simple(:invocation)) do |locals|
      locals[:invocation]
    end

    rule(:object => simple(:object), :property_name => simple(:property_name)) do |locals|
      property_name = locals[:property_name]
      location = location_for(locals[:origin], property_name)
      Rip::Nodes::Property.new(location, locals[:object], property_name)
    end

    rule(:property => simple(:property)) do |locals|
      locals[:property]
    end

    rule(:lhs => simple(:lhs), :location => simple(:location), :rhs => simple(:rhs)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Assignment.new(location, locals[:lhs], locals[:rhs])
    end

    rule(:assignment => simple(:assignment)) do |locals|
      locals[:assignment]
    end

    {
      :dash_rocket => Rip::Nodes::Lambda,
      :fat_rocket => Rip::Nodes::Lambda
    }.each do |keyword, klass|
      rule(keyword => simple(keyword), :parameters => sequence(:parameters), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        klass.new(location, Rip::Utilities::Keywords[keyword], locals[:parameters], body)
      end
    end

    {
      :case => Rip::Nodes::Case,
      :class => Rip::Nodes::Class
    }.each do |keyword, klass|
      rule(keyword => simple(keyword), :location_arguments => simple(:location_arguments), :arguments => sequence(:arguments), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        klass.new(location, locals[:arguments], body)
      end
    end

    {
      :catch => Rip::Nodes::Catch,
      :if => Rip::Nodes::If,
      :unless => Rip::Nodes::Unless
    }.each do |keyword, klass|
      rule(keyword => simple(keyword), :argument => simple(:argument), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        klass.new(location, locals[:argument], body)
      end
    end

    rule(:switch => simple(:switch), :argument => simple(:argument), :body => sequence(:body)) do |locals|
      location = location_for(locals[:origin], locals[:switch])
      case_blocks, else_block = locals[:body].partition { |block| block.is_a?(Rip::Nodes::Case) }
      Rip::Nodes::Switch.new(location, locals[:argument], case_blocks, else_block.first)
    end

    {
      :try => Rip::Nodes::Try,
      :finally => Rip::Nodes::Finally,
      :else => Rip::Nodes::Else
    }.each do |keyword, klass|
      rule(keyword => simple(keyword), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        klass.new(location, body)
      end
    end

    %i[ catch_block if_block unless_block try_block finally_block else_block ].each do |block|
      rule(block => simple(block)) do |locals|
        locals[block]
      end
    end
  end
end
