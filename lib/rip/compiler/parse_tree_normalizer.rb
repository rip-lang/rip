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

    rule(:class => simple(:class), :body => sequence(:body)) do |locals|
      {
        :class => locals[:class],
        :arguments => [],
        :body => locals[:body]
      }
    end

    rule(:switch => simple(:switch), :body => sequence(:body)) do |locals|
      {
        :switch => locals[:switch],
        :argument => nil,
        :body => locals[:body]
      }
    end



    def apply(tree, context = nil)
      _tree = normalize(tree)
      super(_tree, context)
    end

    def normalize(tree)
      case tree
      when Array
        normalize_array(tree)
      when Hash
        normalize_hash(tree)
      else
        tree
      end
    end

    def normalize_array(tree)
      tree.map { |leaf| normalize(leaf) }
    end

    def normalize_hash(tree)
      phrase_or_parts = tree[:phrase]
      case phrase_or_parts
      when Array
        tree.merge(:phrase => normalize_phrase_parts(phrase_or_parts))
      when Hash
        normalize(phrase_or_parts)
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
              :value => normalize(part[:key_value_pair][:value])
            }
          }
        when :range
          {
            :range => {
              :start => phrase_base,
              :end => normalize(part[:range][:end]),
              :exclusivity => part[:range][:exclusivity]
            }
          }
        when :property_assignment
          {
            :assignment => {
              :lhs => normalize(phrase_base),
              :rhs => normalize(part[:property_assignment][:rhs])
            }
          }
        when :operator_invocation
          {
            :invocation => {
              :callable => {
                :property => {
                  :object => normalize(phrase_base),
                  :property_name => part[:operator_invocation][:operator]
                }
              },
              :arguments => [ normalize(part[:operator_invocation][:argument]) ]
            }
          }
        when :regular_invocation
          {
            :invocation => {
              :callable => phrase_base,
              :arguments => normalize(part[:regular_invocation][:arguments])
            }
          }
        when :index_invocation
          {
            :invocation => {
              :callable => {
                :property => {
                  :object => normalize(phrase_base),
                  :property_name => (part[:index_invocation][:open] + part[:index_invocation][:close])
                }
              },
              :arguments => normalize(part[:index_invocation][:arguments])
            }
          }
        when :property_name
          {
            :property => {
              :object => normalize(phrase_base),
              :property_name => normalize(part[:property_name][:reference])
            }
          }
        else
          part
        end
      end
    end
  end
end
