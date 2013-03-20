require 'parslet'

module Rip::Compiler
  # FIXME remove :property_chain nonsense
  class Transform < Parslet::Transform
    rule(:comment => simple(:comment)) { Rip::Nodes::Comment.new comment.to_s }

    rule(:character => simple(:character), :property_chain => sequence(:property_chain)) { Rip::Nodes::Character.new character }

    rule(:string => simple(:string), :property_chain => sequence(:property_chain)) { Rip::Nodes::String.new string }
    rule(:here_doc_start => simple(:here_doc_start), :string => simple(:string), :here_doc_end => simple(:here_doc_end), :property_chain => sequence(:property_chain)) { Rip::Nodes::String.new string }

    rule(:regex => simple(:regex), :property_chain => sequence(:property_chain)) { Rip::Nodes::RegularExpression.new regex }

    rule(:integer => simple(:integer), :property_chain => sequence(:property_chain)) { Rip::Nodes::Integer.new integer }
    rule(:integer => simple(:integer), :sign => simple(:sign), :property_chain => sequence(:property_chain)) { Rip::Nodes::Integer.new integer, sign }

    rule(:decimal => simple(:decimal), :property_chain => sequence(:property_chain)) { Rip::Nodes::Decimal.new decimal }
    rule(:decimal => simple(:decimal), :sign => simple(:sign), :property_chain => sequence(:property_chain)) { Rip::Nodes::Decimal.new decimal, sign }

    rule(:nil => simple(:nil), :property_chain => sequence(:property_chain)) { Rip::Nodes::Nil.new }
  end
end
