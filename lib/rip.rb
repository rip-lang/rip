require 'pathname'

module Rip
  def self.project_path
    Pathname('.').expand_path
  end

  def self.root
    Pathname File.expand_path('..', __FILE__)
  end
end
