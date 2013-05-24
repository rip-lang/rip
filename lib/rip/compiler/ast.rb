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

    def self.module_for(location, lines)
      body = Rip::Nodes::BlockBody.new(location, lines)
      Rip::Nodes::Module.new(location, body)
    end

    rule(:module => simple(:lines)) do |locals|
      lines = []
      location = Rip::Utilities::Location.new(locals[:origin], 0, 1, 1)
      module_for(location, lines)
    end

    rule(:module => sequence(:lines)) do |locals|
      lines = locals[:lines]
      first = lines.first
      location = first ? first.location : Rip::Utilities::Location.new(locals[:origin], 0, 1, 1)
      module_for(location, lines)
    end

    {
      :exit => Rip::Nodes::Exit,
      :return => Rip::Nodes::Return,
      :throw => Rip::Nodes::Throw
    }.each do |keyword, klass|
      rule(keyword => simple(keyword)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        payload = Rip::Nodes::BlockBody.new(location, [])
        klass.new(location, payload)
      end

      rule(keyword => simple(keyword), :payload => simple(:payload)) do |locals|
        location = location_for(locals[:origin], locals[keyword])
        klass.new(location, locals[:payload])
      end
    end

    rule(:reference => simple(:reference)) do |locals|
      reference = locals[:reference]
      location = location_for(locals[:origin], reference)
      Rip::Nodes::Reference.new(location, reference)
    end

    rule(:year => simple(:year), :month => simple(:month), :day => simple(:day)) do |locals|
      location = location_for(locals[:origin], locals[:year])
      Rip::Nodes::Date.new(location, locals[:year], locals[:month], locals[:day])
    end

    rule(:sign => simple(:sign), :hour => simple(:hour), :minute => simple(:minute)) do |locals|
      Rip::Nodes::Time::Offset.new(locals[:sign], locals[:hour], locals[:minute])
    end

    rule(:hour => simple(:hour), :minute => simple(:minute), :second => simple(:second), :sub_second => simple(:sub_second), :offset => simple(:offset)) do |locals|
      location = location_for(locals[:origin], locals[:hour])
      Rip::Nodes::Time.new(location, locals[:hour], locals[:minute], locals[:second], locals[:sub_second], locals[:offset])
    end

    rule(:date => simple(:date), :time => simple(:time)) do |locals|
      location = locals[:date].location
      Rip::Nodes::DateTime.new(location, locals[:date], locals[:time])
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

    rule(:location => simple(:location), :character => simple(:character)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Character.new(location, locals[:character])
    end

    rule(:location => simple(:location), :string => sequence(:characters)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::String.new(location, locals[:characters])
    end

    rule(:location => simple(:location), :list => sequence(:items)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::List.new(location, locals[:items])
    end

    rule(:location => simple(:location), :map => sequence(:key_value_pairs)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Map.new(location, locals[:key_value_pairs])
    end

    rule(:location => simple(:location), :regex => sequence(:pattern)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::RegularExpression.new(location, locals[:pattern])
    end

    rule(:key => simple(:key), :location => simple(:location), :value => simple(:value)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::KeyValue.new(location, locals[:key], locals[:value])
    end

    rule(:start => simple(:start), :location => simple(:location), :exclusivity => simple(:exclusivity), :end => simple(:end)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Range.new(location, locals[:start], locals[:end], !locals[:exclusivity].nil?)
    end

    rule(:callable => simple(:callable), :location => simple(:location), :arguments => sequence(:arguments)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Invocation.new(location, locals[:callable], locals[:arguments])
    end

    rule(:object => simple(:object), :location => simple(:location), :property_name => simple(:property_name)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Property.new(location, locals[:object], locals[:property_name])
    end

    rule(:lhs => simple(:lhs), :location => simple(:location), :rhs => simple(:rhs)) do |locals|
      location = location_for(locals[:origin], locals[:location])
      Rip::Nodes::Assignment.new(location, locals[:lhs], locals[:rhs])
    end

    rule(:start => simple(:start), :interpolation => sequence(:lines), :end => simple(:end)) do |locals|
      location = location_for(locals[:origin], locals[:start])
      body = block_body(locals[:origin], locals[:start], locals[:lines])
      Rip::Nodes::Interpolation.new(location, body)
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
      rule(keyword => simple(keyword), :arguments => sequence(:arguments), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
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
        Rip::Utilities::TemporaryBlock.new(location, body, locals[:argument])
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
      Rip::Utilities::TemporaryBlock.new(location, body)
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
