ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler'

  Bundler.setup
end

require 'pathname'

module Rip
  def self.interpret(source, origin = :nether)
    parser = Rip::Compiler::Parser.new(origin, source)
    Rip::Compiler::Driver.new(parser.syntax_tree).interpret
  end

  def self.project_path
    Pathname.new(@path || '.').expand_path
  end

  def self.project_path=(path)
    @path = path
  end

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
