require 'coveralls'

Coveralls.wear!

require 'pathname'
require 'parslet'
require 'parslet/convenience'
require 'parslet/rig/rspec'
require 'pry'
require 'ruby-prof'

require_relative '../lib/rip'

Pathname.glob(Pathname(__dir__) + 'support' + '**' + '*.rb').each { |file| require file }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.filter_run_excluding :blur => true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

  config.color = true

  config.include RSpecHelpers

  config.extend RSpecHelpers
end
