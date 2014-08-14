require 'coveralls'

Coveralls.wear!

require 'aruba/api'
require 'pathname'
require 'parslet'
require 'parslet/convenience'
require 'parslet/rig/rspec'
require 'pry'
require 'ruby-prof'

require_relative '../lib/rip'

Pathname.glob(Pathname(__dir__) + 'support' + '**' + '*.rb').each { |file| require file }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.filter_run_excluding :blur => true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

  config.color = true

  config.include Aruba::Api
  config.include RSpecHelpers

  config.extend RSpecHelpers
end
