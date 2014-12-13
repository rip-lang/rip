ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler'

  Bundler.setup
end

$LOAD_PATH.unshift(File.expand_path(__dir__ + '/../lib'))

require 'pathname'

module Rip
  def self.logo
    <<-'RIP'
         _            _          _
        /\ \         /\ \       /\ \
       /  \ \        \ \ \     /  \ \
      / /\ \ \       /\ \_\   / /\ \ \
     / / /\ \_\     / /\/_/  / / /\ \_\
    / / /_/ / /    / / /    / / /_/ / /
   / / /__\/ /    / / /    / / /__\/ /
  / / /_____/    / / /    / / /_____/
 / / /\ \ \  ___/ / /__  / / /
/ / /  \ \ \/\__\/_/___\/ / /
\/_/    \_\/\/_________/\/_/
    RIP
  end

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

require 'rip/cli'

require 'rip/core'
require 'rip/exceptions'
require 'rip/nodes'
require 'rip/utilities'

require 'rip/about'
require 'rip/compiler'
require 'rip/loaders'
