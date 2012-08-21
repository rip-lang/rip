require 'parslet'

require 'rip/ast/comment'
require 'rip/ast/nil'
require 'rip/ast/true'
require 'rip/ast/false'
require 'rip/ast/integer'
require 'rip/ast/decimal'
require 'rip/ast/character'
require 'rip/ast/string'
require 'rip/ast/regular_expression'
require 'rip/ast/class'
require 'rip/ast/lambda'
require 'rip/ast/reference'
require 'rip/ast/hash'
require 'rip/ast/key_value_pair'
require 'rip/ast/list'
require 'rip/ast/range'
require 'rip/ast/property'
require 'rip/ast/assignment'

module Rip
  class Transformer < Parslet::Transformer
  end
end
