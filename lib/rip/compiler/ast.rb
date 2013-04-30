require 'ostruct'
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

    rule(:list => sequence(:items)) do |locals|
      location = locals[:items].first.location
      Rip::Nodes::List.new(location, locals[:items])
    end

    rule(:map => sequence(:key_value_pairs)) do |locals|
      location = locals[:key_value_pairs].first.location
      Rip::Nodes::Map.new(location, locals[:key_value_pairs])
    end

    rule(:regex => sequence(:pattern)) do |locals|
      location = locals[:pattern].first.location
      Rip::Nodes::RegularExpression.new(location, locals[:pattern])
    end

    rule(:key => simple(:key), :value => simple(:value)) do |locals|
      location = locals[:key].location
      Rip::Nodes::KeyValue.new(location, locals[:key], locals[:value])
    end

    rule(:start => simple(:start), :end => simple(:end), :exclusivity => simple(:exclusivity)) do |locals|
      location = locals[:start].location
      Rip::Nodes::Range.new(location, locals[:start], locals[:end], !locals[:exclusivity].nil?)
    end

    rule(:callable => simple(:callable), :location => simple(:location), :arguments => sequence(:arguments)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Invocation.new(location, locals[:callable], locals[:arguments])
    end

    rule(:object => simple(:object), :property_name => simple(:property_name)) do |locals|
      property_name = locals[:property_name]
      location = location_for(locals[:origin], property_name)
      Rip::Nodes::Property.new(location, locals[:object], property_name)
    end

    rule(:lhs => simple(:lhs), :location => simple(:location), :rhs => simple(:rhs)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Assignment.new(location, locals[:lhs], locals[:rhs])
    end

    rule(:start => simple(:start), :interpolation => sequence(:lines), :end => simple(:end)) do |locals|
      location = location_for(locals[:origin], locals[:start])
      Rip::Nodes::Interpolation.new(location, locals[:lines])
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
      :if => Rip::Nodes::If,
      :unless => Rip::Nodes::Unless
    }.each do |keyword, klass|
      keyword_block = "#{keyword}_block".to_sym

      rule(keyword => simple(keyword), :argument => simple(:argument), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        OpenStruct.new(:location => location, :argument => locals[:argument], :body => body)
      end

      rule(keyword_block => simple(keyword)) do |locals|
        else_body = Rip::Nodes::BlockBody.new(locals[keyword].body.location, [])
        klass.new(locals[keyword].location, locals[keyword].argument, locals[keyword].body, else_body)
      end

      rule(keyword_block => simple(keyword), :else_block => simple(:else)) do |locals|
        klass.new(locals[keyword].location, locals[keyword].argument, locals[keyword].body, locals[:else].body)
      end
    end

    rule(:switch => simple(:switch), :argument => simple(:argument), :case_blocks => sequence(:case_blocks), :else_block => simple(:else_block)) do |locals|
      location = location_for(locals[:origin], locals[:switch])
      Rip::Nodes::Switch.new(location, locals[:argument], locals[:case_blocks], locals[:else_block])
    end

    rule(:catch => simple(:catch), :argument => simple(:argument), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
      location = location_for(locals[:origin], locals[:catch])
      body = block_body(locals[:origin], locals[:location_body], locals[:body])
      Rip::Nodes::Catch.new(location, locals[:argument], body)
    end

    {
      :else => Rip::Nodes::Else,
      :finally => Rip::Nodes::Finally
    }.each do |keyword, klass|
      rule(keyword => simple(keyword), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        body = block_body(locals[:origin], locals[:location_body], locals[:body])
        klass.new(location, body)
      end
    end

    rule(:try => simple(:try), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
      location = location_for(locals[:origin], locals[:try])
      body = block_body(locals[:origin], locals[:location_body], locals[:body])
      OpenStruct.new(:location => location, :body => body)
    end

    rule(:try_block => simple(:try), :catch_blocks => sequence(:catches)) do |locals|
      {
        :try_block => locals[:try],
        :catch_blocks => locals[:catches],
        :finally_block => Rip::Nodes::Finally.new(location, [])
      }
    end

    rule(:try_block => simple(:try), :catch_blocks => sequence(:catches), :finally_block => simple(:finally)) do |locals|
      Rip::Nodes::Try.new(locals[:try].location, locals[:try].body, locals[:catches], locals[:finally])
    end

    rule(:else_block => simple(:else_block)) do |locals|
      locals[:else_block]
    end
  end
end
