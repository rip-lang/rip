# encoding: utf-8

require_relative '../../test_case'

class ParsersReferenceTest < TestCase
  def test_valid_reference
    [
      'name',
      'Person',
      '==',
      'save!',
      'valid?',
      'long_ref-name',
      '*/-+<>&$~%',
      'one_9',
      'É¹ÇÊ‡É¹oÔ€uÉlâˆ€â„¢'
    ].each do |reference|
      assert_equal reference, parser.reference.parse(reference)[:reference]
    end
  end

  def test_invalid_reference
    [
      'one.two',
      '999',
      '6teen',
      'rip rocks',
      'key:value'
    ].each do |reference|
      assert_raises Parslet::UnconsumedInput, Parslet::ParseFailed, "#{reference} was matched, but should not have been" do
        parser.reference.parse(reference)
      end
    end
  end

  def test_special_reference
    nilly = parser.reference.parse('nilly')
    assert_equal 'nilly', nilly[:reference]

    n = parser.reference.parse('nil')
    assert_equal 'nil', n[:reference][:nil]

    t = parser.reference.parse('true')
    assert_equal 'true', t[:reference][:true]

    f = parser.reference.parse('false')
    assert_equal 'false', f[:reference][:false]

    k = parser.reference.parse('Kernel')
    assert_equal 'Kernel', k[:reference][:kernel]
  end

  def test_assignment
    assignment = parser.assignment.parse('favorite_language = :rip')
    assert_equal 'favorite_language', assignment[:assignment][:reference]
    assert_equal 'rip', assignment[:assignment][:value][:string]
  end
end
