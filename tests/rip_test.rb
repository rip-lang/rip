require_relative 'test_case'

require 'pathname'

class RipTest < TestCase
  def test_project_path
    assert_equal Pathname(Dir.pwd).expand_path, Rip.project_path
  end

  #def test_project_path=
  #  Rip.project_path = 'some/other/directory'
  #  assert_equal Pathname('some/other/directory').expand_path, Rip.project_path
  #end

  def test_root
    assert_equal Pathname('lib').expand_path, Rip.root
  end
end
