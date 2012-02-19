require_relative '../../test_case'

class ParsersObjectRecursiveLiteralTest < TestCase
  def test_key_value_pair
    kvp = parser.key_value_pair.parse('5: \'five\'')
    assert_equal '5', kvp[:key][:integer]
    assert_equal 'five', kvp[:value][:string]
  end

  def test_range
    range = parser.range.parse('1..3')
    assert_equal '1', range[:start][:integer]
    assert_equal '3', range[:end][:integer]
    assert_nil range[:exclusivity]

    range = parser.range.parse('1...age')
    assert_equal '1', range[:start][:integer]
    assert_equal 'age', range[:end][:reference]
    assert_equal '.', range[:exclusivity]
  end

  def test_hash_literal
    empty_hash = parser.hash_literal.parse('{}')
    assert_equal [], empty_hash[:hash]

    single_hash = parser.hash_literal.parse('{:name: :Thomas}')
    assert_equal 'name', single_hash[:hash].first[:key][:string]
    assert_equal 'Thomas', single_hash[:hash].first[:value][:string]

    rip_hash = <<-RIP_HASH
{
  :age: 31,
  :name: :Thomas
}
    RIP_HASH
    multi_hash = parser.hash_literal.parse(rip_hash.strip)
    assert_equal 'age', multi_hash[:hash].first[:key][:string]
    assert_equal '31', multi_hash[:hash].first[:value][:integer]
    assert_equal 'name', multi_hash[:hash].last[:key][:string]
    assert_equal 'Thomas', multi_hash[:hash].last[:value][:string]
  end

  def test_list
    empty_list = parser.list.parse('[]')
    assert_equal [], empty_list[:list]

    single_list = parser.list.parse('[:Thomas]')
    assert_equal 'Thomas', single_list[:list].first[:string]

    rip_list = <<-RIP_LIST
[
  31,
  :Thomas
]
    RIP_LIST
    multi_list = parser.list.parse(rip_list.strip)
    assert_equal '31', multi_list[:list].first[:integer]
    assert_equal 'Thomas', multi_list[:list].last[:string]
  end
end
