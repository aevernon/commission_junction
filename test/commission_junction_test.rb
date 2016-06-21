require 'test_helper'

class CommissionJunctionTest < Minitest::Test
  def assert_nothing_raised(*)
    yield
  end

  def test_new_cj_with_no_params
    assert_raises ArgumentError do
      CommissionJunction.new
    end
  end

  def test_new_cj_with_one_param
    assert_raises ArgumentError do
      CommissionJunction.new('fake')
    end
  end

  def test_new_cj_with_nil_param
    assert_raises ArgumentError do
      CommissionJunction.new(nil, 'website_id')
    end

    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', nil)
    end

    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', nil)
    end
  end

  def test_new_cj_with_empty_param
    assert_raises ArgumentError do
      CommissionJunction.new('', 'website_id')
    end

    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', '')
    end
  end

  def test_new_cj_with_non_string_param
    assert_raises ArgumentError do
      CommissionJunction.new(123456, 'website_id')
    end

    assert_nothing_raised ArgumentError do
      CommissionJunction.new('developer_key', 123456)
    end
  end

  def test_new_cj_with_non_fixnum_timeout
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', '10')
    end
  end

  def test_new_cj_with_non_positive_timeout
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', 0)
    end

    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', -1)
    end
  end

  def test_new_cj_with_correct_types
    assert_nothing_raised do
      assert_instance_of(CommissionJunction, CommissionJunction.new('developer_key', 'website_id'))
    end

    assert_nothing_raised do
      assert_instance_of(CommissionJunction, CommissionJunction.new('developer_key', 'website_id', 50))
    end
  end

  def test_new_product_with_no_params
    assert_raises ArgumentError do
      CommissionJunction::Product.new
    end
  end

  def test_new_product_with_nil_params
    assert_raises ArgumentError do
      CommissionJunction::Product.new(nil)
    end
  end

  def test_new_product_with_empty_params
    assert_raises ArgumentError do
      CommissionJunction::Product.new({})
    end
  end

  def test_new_product_with_non_hash_params
    assert_raises ArgumentError do
      CommissionJunction::Product.new([1, 2, 3])
    end
  end

  def test_new_product_with_hash_params_and_non_string_keys
    assert_raises ArgumentError do
      CommissionJunction::Product.new(:name => 'blue jeans', :price => '49.95')
    end
  end

  def test_new_product_with_hash_params_and_string_keys
    assert_nothing_raised do
      product = CommissionJunction::Product.new('name' => 'blue jeans', 'price' => '49.95')
      assert_instance_of(CommissionJunction::Product, product)
      assert_respond_to(product, :name)
      assert_equal('blue jeans', product.name)
      assert_respond_to(product, :price)
      assert_equal('49.95', product.price)
    end
  end

  def test_product_search_with_no_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search
    end
  end

  def test_product_search_with_nil_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search(nil)
    end
  end

  def test_product_search_with_empty_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search({})
    end
  end

  def test_product_search_with_non_hash_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search([1, 2, 3])
    end
  end

  def test_product_search_with_bad_key
    cj = CommissionJunction.new('bad_key', 'website_id')

    assert_raises ArgumentError do
      cj.product_search('keywords' => '+some +product')
    end
  end

  def test_product_search_with_keywords_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

    # Zero results
    assert_nothing_raised do
      cj.product_search('keywords' => 'no_matching_results')
    end

    check_search_results(cj)

    # One result
    assert_nothing_raised do
      cj.product_search('keywords' => '+blue +jeans', 'records-per-page' => '1')
    end

    check_search_results(cj)

    # Multiple results
    assert_nothing_raised do
      cj.product_search('keywords' => '+blue +jeans', 'records-per-page' => '2')
    end

    check_search_results(cj)

    # Short timeout
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'], 1)

    assert_nothing_raised do
      cj.product_search('keywords' => 'One Great Blue Jean~No Limits', 'records-per-page' => '1')
    end

    check_search_results(cj)
  end

  def check_search_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |product|
      assert_instance_of(CommissionJunction::Product, product)
      assert_respond_to(product, :ad_id)
      assert_respond_to(product, :advertiser_id)
      assert_respond_to(product, :advertiser_name)
      assert_respond_to(product, :buy_url)
      assert_respond_to(product, :catalog_id)
      assert_respond_to(product, :currency)
      assert_respond_to(product, :description)
      assert_respond_to(product, :image_url)
      assert_respond_to(product, :in_stock)
      assert_respond_to(product, :isbn)
      assert_respond_to(product, :manufacturer_name)
      assert_respond_to(product, :manufacturer_sku)
      assert_respond_to(product, :name)
      assert_respond_to(product, :price)
      assert_respond_to(product, :retail_price)
      assert_respond_to(product, :sale_price)
      assert_respond_to(product, :sku)
      assert_respond_to(product, :upc)
    end
  end

  def test_advertiser_lookup_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

    # Use default lookup parameters.
    assert_nothing_raised do
      cj.advertiser_lookup
    end

    check_advertiser_lookup_results(cj)

    # One result
    assert_nothing_raised do
      cj.advertiser_lookup('advertiser-ids' => 'joined', 'page-number' => '1')
    end

    check_advertiser_lookup_results(cj)

    # Multiple results
    assert_nothing_raised do
      cj.advertiser_lookup('keywords' => '+blue +jeans', 'records-per-page' => '2')
    end

    check_advertiser_lookup_results(cj)

    # Short timeout
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'], 1)

    assert_nothing_raised do
      cj.advertiser_lookup('keywords' => 'One Great Blue Jean~No Limits', 'records-per-page' => '1')
    end

    check_advertiser_lookup_results(cj)
  end

  def check_advertiser_lookup_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |advertiser|
      assert_instance_of(CommissionJunction::Advertiser, advertiser)
      assert_respond_to(advertiser, :advertiser_id)
      assert_respond_to(advertiser, :advertiser_name)
      assert_respond_to(advertiser, :language)
      assert_respond_to(advertiser, :link_types)
      assert_respond_to(advertiser, :network_rank)
      assert_respond_to(advertiser, :performance_incentives)
      assert_respond_to(advertiser, :primary_category)
      assert_respond_to(advertiser, :program_url)
      assert_respond_to(advertiser, :relationship_status)
      assert_respond_to(advertiser, :seven_day_epc)
      assert_respond_to(advertiser, :three_month_epc)
    end
  end

  def test_categories_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

    assert cj.categories.size > 0
  end

  def test_commissions_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

    assert_nothing_raised do
      cj.commissions
    end

    check_commission_lookup_results(cj)

    assert_nothing_raised do
      cj.commissions('date-type' => 'posting')
    end

    check_commission_lookup_results(cj)
  end

  def check_commission_lookup_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |commission|
      assert_instance_of(CommissionJunction::Commission, commission)
      assert_respond_to(commission, :action_status)
      assert_respond_to(commission, :action_type)
      assert_respond_to(commission, :action_tracker_id)
      assert_respond_to(commission, :action_tracker_name)
      assert_respond_to(commission, :aid)
      assert_respond_to(commission, :commission_id)
      assert_respond_to(commission, :country)
      assert_respond_to(commission, :event_date)
      assert_respond_to(commission, :locking_date)
      assert_respond_to(commission, :order_id)
      assert_respond_to(commission, :original)
      assert_respond_to(commission, :original_action_id)
      assert_respond_to(commission, :posting_date)
      assert_respond_to(commission, :website_id)
      assert_respond_to(commission, :cid)
      assert_respond_to(commission, :advertiser_name)
      assert_respond_to(commission, :commission_amount)
      assert_respond_to(commission, :order_discount)
      assert_respond_to(commission, :sid)
      assert_respond_to(commission, :sale_amount)
    end
  end

  def test_item_detail_with_no_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').item_detail
    end
  end

  def test_item_detail_with_nil_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').item_detail(nil)
    end
  end

  def test_item_detail_with_too_few_ids
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').item_detail([])
    end
  end

  def test_item_detail_with_too_many_ids
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').item_detail(Array.new(51))
    end
  end

  def test_item_detail_with_non_array_params
    assert_raises ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').item_detail('string')
    end
  end

  def test_item_detail_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])
    ids = []

    cj.commissions.each do |commission|
      ids << commission.original_action_id
    end

    skip "Skipping live testing of item_detail because there are no original action IDs in your account." unless ids.size > 0

    assert_nothing_raised do
      cj.item_detail(ids[0, 1])
      check_item_detail_results(cj)
      cj.item_detail(ids[0, 2])
      check_item_detail_results(cj)
    end
  end

  def check_item_detail_results(results)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |item_detail|
      assert_instance_of(Hash, item_detail)
      assert item_detail.has_key?('original_action_id')
      assert item_detail.has_key?('item')

      item = item_detail['item']
      item = item.first if item.is_a?(Array)

      assert item.has_key?('sku')
      assert item.has_key?('quantity')
      assert item.has_key?('posting_date')
      assert item.has_key?('commission_id')
      assert item.has_key?('sale_amount')
      assert item.has_key?('discount')
      assert item.has_key?('publisher_commission')

    end
  end

  def test_link_search_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    skip "#{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing." unless File.exist?(key_file)

    credentials = YAML.load(File.read(key_file))
    cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

    assert_nothing_raised do
      cj.link_search('keywords' => '+blue +jeans', 'advertiser-ids' => 'joined')
    end

    check_link_search_results(cj)
  end

  def check_link_search_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |link|
      assert_instance_of(CommissionJunction::Link, link)
      assert_respond_to(link, :advertiser_id)
      assert_respond_to(link, :click_commission)
      assert_respond_to(link, :creative_height)
      assert_respond_to(link, :creative_width)
      assert_respond_to(link, :lead_commission)
      assert_respond_to(link, :link_code_html)
      assert_respond_to(link, :link_code_javascript)
      assert_respond_to(link, :destination)
      assert_respond_to(link, :description)
      assert_respond_to(link, :link_id)
      assert_respond_to(link, :link_name)
      assert_respond_to(link, :link_type)
      assert_respond_to(link, :advertiser_name)
      assert_respond_to(link, :performance_incentive)
      assert_respond_to(link, :promotion_type)
      assert_respond_to(link, :promotion_start_date)
      assert_respond_to(link, :promotion_end_date)
      assert_respond_to(link, :relationship_status)
      assert_respond_to(link, :sale_commission)
      assert_respond_to(link, :seven_day_epc)
      assert_respond_to(link, :three_month_epc)
    end
  end

  def set_up_service
    CommissionJunction.new('developer_key', 123456)
  end

  def test_contents_extractor_with_first_level
    contents = "abc"
    response = {'cj_api' => {'first' => contents}}

    cj = set_up_service

    assert_equal(contents, cj.extract_contents(response, "first"))
  end

  def test_contents_extractor_with_second_level
    contents = "abc"
    response = {'cj_api' => {'first' => {'second' => contents}}}

    cj = set_up_service

    assert_equal(contents, cj.extract_contents(response, "first", "second"))
  end

  def test_contents_extractor_with_error_message
    contents = "abc"
    response = {'cj_api' => {'error_message' => contents}}

    cj = set_up_service

    assert_raises ArgumentError do
      cj.extract_contents(response, "first")
    end
  end

  def test_contents_extractor_with_no_cj_api
    response = {}

    cj = set_up_service

    assert_raises ArgumentError do
      cj.extract_contents(response, "first")
    end
  end

  def set_up_cj_object
    CommissionJunction::CjObject.new({"a" => "a"})
  end

  def test_key_conversion_with_spaces
    cjo = set_up_cj_object

    assert_equal("abc_def", cjo.clean_key_name("abc def"))
  end

  def test_key_conversion_with_trailing_spaces
    cjo = set_up_cj_object

    assert_equal("abcdef", cjo.clean_key_name("abcdef "))
  end

  def test_initializing_product_using_key_with_spaces
    product = CommissionJunction::Product.new("abc def" => "123")
    assert_equal(product.abc_def, "123")
  end
end
