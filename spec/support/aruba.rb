require 'aruba/api'
require 'aruba/reporting'

RSpec.configure do |config|
  config.include Aruba::Api

  config.after(:each) { restore_env }

  ENV['PATH'] = [
    Rip.root.parent.join('bin'),
    ENV['PATH']
  ].join(File::PATH_SEPARATOR)
end
