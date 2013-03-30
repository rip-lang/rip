require_relative '../lib/rip'

require 'pathname'
require 'parslet'
require 'parslet/convenience'
require 'parslet/rig/rspec'
require 'pry'
require 'ruby-prof'

Dir[Pathname(__dir__).join('support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.filter_run_excluding :blur => true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.color = true

  config.include RSpecHelpers

  config.extend RSpecHelpers
end
