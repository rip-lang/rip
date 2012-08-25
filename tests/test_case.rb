require 'minitest/autorun'
require 'pathname'

require 'rip/ast'
require 'rip/parser'

class TestCase < MiniTest::Spec
  let(:samples_path) { Pathname("#{__FILE__}/../samples").expand_path }
  let(:parser) { Rip::Parser.new }

  def ast(code)
    Rip::AST.new(parser.parse(code)).tree
  end
end
