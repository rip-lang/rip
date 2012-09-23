require 'debugger'
require 'pathname'

require_relative '../lib/rip/boot'
require_relative '../lib/rip/ast'
require_relative '../lib/rip/parser'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  def samples_path
    Pathname("#{__FILE__}/../samples").expand_path
  end

  def parser
    Rip::Parser.new
  end

  def apt(code)
    Rip::Parser.new.parse(code)
  end

  def ast(code)
    Rip::AST.new(apt(code)).tree
  end
end
