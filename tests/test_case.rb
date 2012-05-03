require 'minitest/autorun'
require 'pathname'

require 'rip/parser'

class TestCase < MiniTest::Spec
  let(:samples_path) { Pathname("#{__FILE__}/../samples").expand_path }
  let(:parser) { Rip::Parser.new }
end
