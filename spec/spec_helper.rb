require 'pathname'
require 'parslet'
require 'parslet/convenience'
require 'parslet/rig/rspec'
require 'pry'

require_relative '../lib/rip/boot'
require_relative '../lib/rip/ast'
require_relative '../lib/rip/parser'

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

  def samples_path
    Pathname("#{__FILE__}/../fixtures").expand_path
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

  def rip_parsed_string(string)
    string.split('').map do |s|
      { :raw_string => s }
    end
  end
end
