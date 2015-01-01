require 'coveralls'

Coveralls.wear!

require 'pathname'
require 'pry'
require 'ruby-prof'

require_relative '../source/rip'

Pathname.glob(Pathname.new(__dir__) + 'support' + '**' + '*.rb').each { |file| require file }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.filter_run_excluding :blur => true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'

  config.color = true
end
