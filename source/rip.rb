ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler'

  Bundler.setup
end

require 'pathname'

module Rip
  def self.root
    Pathname.new(__dir__).expand_path
  end
end

require_relative 'rip/cli'

require_relative 'rip/core'
require_relative 'rip/exceptions'
require_relative 'rip/nodes'
require_relative 'rip/utilities'

require_relative 'rip/about'
require_relative 'rip/compiler'
require_relative 'rip/loaders'
