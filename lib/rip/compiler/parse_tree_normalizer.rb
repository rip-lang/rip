require 'parslet'

module Rip::Compiler
  class ParseTreeNormalizer < Parslet::Transform
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
