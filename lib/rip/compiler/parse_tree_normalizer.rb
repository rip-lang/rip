require 'parslet'

module Rip::Compiler
  class ParseTreeNormalizer < Parslet::Transform
    ESCAPES = {
      '\'' => '\'',
      '"' => '"',
      'b' => "\b",
      'a' => "\a",
      'e' => "\e",
      'f' => "\f",
      'n' => "\n",
      '#' => '#',
      'r' => "\r",
      't' => "\t"
    }

    def apply(tree, context = nil)
      _tree = normalize_atom(tree)
      super(_tree)
    end


    def normalize_characters(tree)
      case
      when tree.is_a?(Hash) && tree.has_key?(:regex)
        normalize_character_hash(tree, :regex)
      when tree.is_a?(Hash) && tree.has_key?(:string)
        normalize_character_hash(tree, :string)
      else
        tree
      end
    end

    def normalize_character_hash(tree, type)
      parts = tree[type].inject([]) do |memo, part|
        if part[:character] && memo.last && memo.last[type]
          memo.last[type] << part
        elsif part[:character]
          memo << { type => [ part ] }
        else
          memo << part
        end

        memo
      end

      parts.inject do |memo, part|
        location = part[:start] ||
          memo[:end] ||
          memo[:atom].last[:operator_invocation][:argument][:end]
        plus = self.class.slice(location, '+')

        {
          :atom => [
            memo,
            {
              :operator_invocation => {
                :operator => plus,
                :argument => part
              }
            }
          ]
        }
      end
    end


    def normalize_atom(tree)
      _tree = normalize_characters(tree)

      case _tree
      when Array
        normalize_atom_array(_tree)
      when Hash
        normalize_atom_hash(_tree)
      else
        _tree
      end
    end

    def normalize_atom_array(tree)
      tree.map { |leaf| normalize_atom(leaf) }
    end

    def normalize_atom_hash(tree)
      atom_or_parts = tree[:atom]
      case atom_or_parts
      when Array
        normalize_atom_parts(atom_or_parts)
      when Hash
        normalize_atom(atom_or_parts)
      else
        tree
      end
    end

    def normalize_atom_parts(atom_or_parts)
      atom_or_parts.inject do |atom_base, part|
        case
        when part.has_key?(:assignment)
          {
            :lhs => normalize_atom(atom_base),
            :location => part[:assignment][:location],
            :rhs => normalize_atom(part[:assignment][:rhs])
          }
        when part.has_key?(:key_value_pair)
          {
            :key => atom_base,
            :location => normalize_atom(part[:key_value_pair][:location]),
            :value => normalize_atom(part[:key_value_pair][:value])
          }
        when part.has_key?(:range)
          {
            :start => atom_base,
            :location => normalize_atom(part[:range][:location]),
            :exclusivity => part[:range][:exclusivity],
            :end => normalize_atom(part[:range][:end])
          }
        when part.has_key?(:regular_invocation)
          {
            :callable => atom_base,
            :location => part[:regular_invocation][:location],
            :arguments => normalize_atom(part[:regular_invocation][:arguments])
          }
        when part.has_key?(:index_invocation)
          {
            :callable => {
              :object => normalize_atom(atom_base),
              :location => part[:index_invocation][:open],
              :property_name => (part[:index_invocation][:open] + part[:index_invocation][:close])
            },
            :location => part[:index_invocation][:open],
            :arguments => normalize_atom(part[:index_invocation][:arguments])
          }
        when part.has_key?(:operator_invocation)
          {
            :callable => {
              :object => normalize_atom(atom_base),
              :location => part[:operator_invocation][:operator],
              :property_name => part[:operator_invocation][:operator]
            },
            :location => part[:operator_invocation][:operator],
            :arguments => [ normalize_atom(part[:operator_invocation][:argument]) ]
          }
        when part.has_key?(:property_name)
          {
            :object => normalize_atom(atom_base),
            :location => part[:location],
            :property_name => normalize_atom(part[:property_name])
          }
        else
          part
        end
      end
    end


    def self.slice(location_slice, text)
      Parslet::Slice.new(text.to_s, location_slice.offset, location_slice.line_cache)
    end


    rule(:location => simple(:location), :escaped_token => simple(:token)) do |locals|
      token = locals[:token].to_s
      slice(locals[:location], ESCAPES[token] || token)
    end

    rule(:location => simple(:location), :escaped_token_unicode => simple(:unicode)) do |locals|
      slice(locals[:location], locals[:unicode].to_s.to_i(16).chr('UTF-8'))
    end

    %i[decimal integer].each do |number|
      rule(number => simple(number)) do |locals|
        {
          :sign => slice(locals[number], '+'),
          number => locals[number]
        }
      end
    end

    %i[dash_rocket fat_rocket].each do |keyword|
      rule(keyword => simple(keyword), :location_body => simple(:location_body), :body => subtree(:body)) do |locals|
        {
          :dash_rocket => locals[keyword],
          :parameters => [],
          :location_body => locals[:location_body],
          :body => locals[:body]
        }
      end
    end

    rule(:class => simple(:class), :location_body => simple(:location_body), :body => subtree(:body)) do |locals|
      {
        :class => locals[:class],
        :arguments => [],
        :location_body => locals[:location_body],
        :body => locals[:body]
      }
    end

    rule(:switch => simple(:switch), :location_body => simple(:location_body), :body => subtree(:body)) do |locals|
      {
        :switch => locals[:switch],
        :argument => nil,
        :location_body => locals[:location_body],
        :body => locals[:body]
      }
    end

    rule(:hour => simple(:hour), :minute => simple(:minute), :second => simple(:second)) do |locals|
      {
        :hour => locals[:hour],
        :minute => locals[:minute],
        :second => locals[:second],
        :sub_second => '0',
        :offset => {
          :sign => '+',
          :hour => '00',
          :minute => '00'
        }
      }
    end

    rule(:hour => simple(:hour), :minute => simple(:minute), :second => simple(:second), :sub_second => simple(:sub_second)) do |locals|
      {
        :hour => locals[:hour],
        :minute => locals[:minute],
        :second => locals[:second],
        :sub_second => locals[:sub_second],
        :offset => {
          :sign => '+',
          :hour => '00',
          :minute => '00'
        }
      }
    end

    rule(:hour => simple(:hour), :minute => simple(:minute), :second => simple(:second), :offset => subtree(:offset)) do |locals|
      {
        :hour => locals[:hour],
        :minute => locals[:minute],
        :second => locals[:second],
        :sub_second => '0',
        :offset => locals[:offset]
      }
    end
  end
end
