require 'pathname'

module Rip
  def self.project_path
    Pathname(@path || '.').expand_path
  end

  def self.project_path=(path)
    @path = path
  end

  def self.root
    Pathname File.expand_path('..', __FILE__)
  end
end
