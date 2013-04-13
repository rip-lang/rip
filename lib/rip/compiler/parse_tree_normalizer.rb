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
      _tree = normalize_phrase(tree)
      super(_tree)
    end

    def normalize_phrase(tree)
      case tree
      when Array
        normalize_phrase_array(tree)
      when Hash
        normalize_phrase_hash(tree)
      else
        tree
      end
    end

    def normalize_phrase_array(tree)
      tree.map { |leaf| normalize_phrase(leaf) }
    end

    def normalize_phrase_hash(tree)
      phrase_or_parts = tree[:phrase]
      case phrase_or_parts
      when Array
        tree.merge(:phrase => normalize_phrase_parts(phrase_or_parts))
      when Hash
        normalize_phrase(phrase_or_parts)
      else
        tree
      end
    end

    def normalize_phrase_parts(phrase_or_parts)
      phrase_or_parts.inject do |phrase_base, part|
        case part.keys.sort.first
        when :key_value_pair
          {
            :key_value_pair => {
              :key => phrase_base,
              :value => normalize_phrase(part[:key_value_pair][:value])
            }
          }
        when :range
          {
            :range => {
              :start => phrase_base,
              :end => normalize_phrase(part[:range][:end]),
              :exclusivity => part[:range][:exclusivity]
            }
          }
        when :property_assignment
          {
            :assignment => {
              :lhs => normalize_phrase(phrase_base),
              :location => part[:property_assignment][:location],
              :rhs => normalize_phrase(part[:property_assignment][:rhs])
            }
          }
        when :operator_invocation
          {
            :operator_invocation => {
              :callable => {
                :property => {
                  :object => normalize_phrase(phrase_base),
                  :property_name => part[:operator_invocation][:operator]
                }
              },
              :location => part[:operator_invocation][:operator][:reference],
              :arguments => [ normalize_phrase(part[:operator_invocation][:argument]) ]
            }
          }
        when :regular_invocation
          {
            :invocation => {
              :callable => phrase_base,
              :location => part[:regular_invocation][:location_arguments],
              :arguments => normalize_phrase(part[:regular_invocation][:arguments])
            }
          }
        when :index_invocation
          {
            :invocation => {
              :callable => {
                :property => {
                  :object => normalize_phrase(phrase_base),
                  :property_name => (part[:index_invocation][:open] + part[:index_invocation][:close])
                }
              },
              :location => part[:index_invocation][:open],
              :arguments => normalize_phrase(part[:index_invocation][:arguments])
            }
          }
        when :property_name
          {
            :property => {
              :object => normalize_phrase(phrase_base),
              :property_name => normalize_phrase(part[:property_name][:reference])
            }
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

    rule(:raw_string => simple(:raw_string)) do |locals|
      { :character => locals[:raw_string] }
    end

    rule(:raw_regex => simple(:raw_regex)) do |locals|
      locals[:raw_regex]
    end

    rule(:class => simple(:class), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
      {
        :class => locals[:class],
        :arguments => [],
        :location_body => locals[:location_body],
        :body => locals[:body]
      }
    end

    rule(:switch => simple(:switch), :location_body => simple(:location_body), :body => sequence(:body)) do |locals|
      {
        :switch => locals[:switch],
        :argument => nil,
        :location_body => locals[:location_body],
        :body => locals[:body]
      }
    end
  end
end
