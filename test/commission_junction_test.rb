require 'test_helper'

class CommissionJunctionTest < Test::Unit::TestCase
  def test_new_with_no_key
    assert_raise ArgumentError do
      CommissionJunction.new
    end
  end

  def test_new_with_nil_key
    assert_raise ArgumentError do
      CommissionJunction.new(nil)
    end
  end

  def test_new_with_empty_key
    assert_raise ArgumentError do
      CommissionJunction.new('')
    end
  end

  def test_new_with_non_string_key
    assert_raise ArgumentError do
      CommissionJunction.new(123456)
    end
  end

  def test_new_with_string_key
    assert_nothing_raised do
      assert_instance_of(CommissionJunction, CommissionJunction.new('test'))
    end
  end

  def test_product_search_with_no_params
    assert_raise ArgumentError do
      CommissionJunction.new('test').product_search
    end
  end

  def test_product_search_with_nil_params
    assert_raise ArgumentError do
      CommissionJunction.new('test').product_search(nil)
    end
  end

  def test_product_search_with_empty_params
    assert_raise ArgumentError do
      CommissionJunction.new('test').product_search({})
    end
  end

  def test_product_search_with_non_hash_params
    assert_raise ArgumentError do
      CommissionJunction.new('test').product_search([1, 2, 3])
    end
  end

  def test_product_search_with_bad_key
    cj = CommissionJunction.new('bad')

    assert_raise ArgumentError do
      cj.product_search('keywords' => '+some +product')
    end
  end
end
