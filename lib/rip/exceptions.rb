module Rip
  module Exceptions
  end
end

require_relative 'exceptions/base'
require_relative 'exceptions/compiler_exception'
require_relative 'exceptions/load_exception'
require_relative 'exceptions/native_exception'
require_relative 'exceptions/runtime_exception'

require_relative 'exceptions/syntax_error'
require_relative 'exceptions/usage_exception'
