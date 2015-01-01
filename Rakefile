# For Bundler.with_clean_env
require 'bundler/setup'

require 'pathname'

require_relative 'source/rip/about'

PACKAGE_NAME = 'rip'
VERSION = Rip::About.version
TRAVELING_RUBY_VERSION = "20141224-#{RUBY_VERSION}"
BUILD_DIR_PREFIX = 'build'

task :default => [ :notes ]

desc 'Enumerate annotations. Optionally takes a pipe-separated list of tags to process'
task :notes, :types do |t, args|
  args.with_defaults :types => 'FIXME|TODO'

  types = args[:types].split '|'
  finder = /.*# ?(?<type>[A-Z]+):? (?<note>.+)$/
  result = Hash.new { |hash, key| hash[key] = {} }

  `git ls-files`.split("\n").each do |p|
    path = Pathname.new(p)
    line_number = 0

    path.each_line do |line|
      line_number += 1

      if match = finder.match(line)
        result[path][line_number] = { :type => match[:type], :note => match[:note] } if types.include? match[:type]
      end
    end rescue nil
  end

  numbers = []

  result.each do |path, lines|
    lines.each do |number, note|
      numbers << number
    end
  end

  number_width = numbers.max.to_s.length
  type_width = types.max_by { |type| type.to_s.length }.to_s.length

  result.each do |path, lines|
    puts "\e[1m#{path}\e[0m:"

    lines.each do |number, note|
      line_number = "[\e[1m#{number.to_s.rjust(number_width)}\e[0m]"
      type = "[\e[0;37m#{note[:type]}\e[0m]"
      puts "  * #{line_number} #{type.ljust(type_width + type.length - note[:type].length)} #{note[:note]}"
    end

    puts
  end
end

desc 'Package Rip'
task :package => [ 'package:linux:x86', 'package:linux:x86_64', 'package:osx' ]

namespace :package do
  namespace :linux do
    desc 'Package your app for Linux x86'
    task :x86 => [:bundle_install, "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz"] do
      create_package('linux-x86')
    end

    desc 'Package your app for Linux x86_64'
    task :x86_64 => [:bundle_install, "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz"] do
      create_package('linux-x86_64')
    end
  end

  desc 'Package your app for OS X'
  task :osx => [:bundle_install, "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz"] do
    create_package('osx')
  end

  desc 'Install gems to local directory'
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort 'You can only \'bundle install\' using Ruby 2.1, because that\'s what Traveling Ruby uses.'
    end

    sh 'rm -rf packaging/tmp'
    sh 'mkdir packaging/tmp'
    sh 'cp Gemfile Gemfile.lock packaging/tmp/'

    Bundler.with_clean_env do
      sh 'cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development:test'
    end

    sh 'rm -rf packaging/tmp'
    sh 'rm -f packaging/vendor/*/*/cache/*'
  end
end

file "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime('linux-x86')
end

file "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime('linux-x86_64')
end

file "packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime('osx')
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"

  sh "rm -rf #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app/bin"
  sh "cp -r bin/rip #{package_dir}/lib/app/bin"
  sh "cp -r source #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/cache/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "cp packaging/wrapper.sh #{package_dir}/rip"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"

  sh "mkdir -p #{BUILD_DIR_PREFIX}"

  if ENV['DIR_ONLY']
    sh "rm -fr #{BUILD_DIR_PREFIX}/#{package_dir}"
    sh "mv #{package_dir} #{BUILD_DIR_PREFIX}"
  else
    sh "tar -czf #{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
    sh "mv #{package_dir}.tar.gz #{BUILD_DIR_PREFIX}"
  end
end

def download_runtime(target)
  sh 'mkdir -p packaging/cache'
  sh "cd packaging/cache && curl -L -O --fail http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end
