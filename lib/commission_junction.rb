require 'commission_junction/version'
require 'ox'
require 'httparty'

# Interact with CJ web services.
# See https://cjcommunity.force.com/s/article/4777058.
class CommissionJunction
  include HTTParty
  default_options.update(verify: false) # Skip SSL certificate verification.
  format(:xml)
  # debug_output $stderr

  attr_reader :total_matched,
              :records_returned,
              :page_number,
              :cj_objects

  WEB_SERVICE_URIS =
    {
      product_search: 'https://product-search.api.cj.com/v2/product-search',
      link_search: 'https://link-search.api.cj.com/v2/link-search',
      advertiser_lookup: 'https://advertiser-lookup.api.cj.com/v3/advertiser-lookup',
      categories: 'https://support-services.api.cj.com/v2/categories',
      commissions: 'https://commission-detail.api.cj.com/v3/commissions',
      item_detail: 'https://commission-detail.api.cj.com/v3/item-detail/'
    }.freeze

  def initialize(developer_key, website_id, timeout = 10)
    raise ArgumentError, "developer_key must be a String; got #{developer_key.class} instead" unless developer_key.is_a?(String)
    raise ArgumentError, "You must supply your developer key.\nSee https://api.cj.com/sign_up.cj" if developer_key.empty?

    website_id = website_id.to_s
    raise ArgumentError, "You must supply your website ID.\nSee cj.com > Account > Web site Settings > PID" if website_id.empty?
    @website_id = website_id

    raise ArgumentError, "timeout must be a Integer; got #{timeout.class} instead" unless timeout.is_a?(Integer)
    raise ArgumentError, "timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @timeout = timeout

    self_class = self.class
    self_class.headers('authorization' => developer_key)
  end

  def categories(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = { 'locale' => 'en' }.merge(params)

    response = self.class.get(WEB_SERVICE_URIS[:categories], query: params, timeout: @timeout)
    @categories = extract_contents(response, 'categories', 'category')
  end

  def advertiser_lookup(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = { 'advertiser-ids' => 'joined' }.merge(params)

    @cj_objects = []

    response = self.class.get(WEB_SERVICE_URIS[:advertiser_lookup], query: params)
    advertisers = extract_contents(response, 'advertisers')

    @total_matched = advertisers['total_matched'].to_i
    @records_returned = advertisers['records_returned'].to_i
    @page_number = advertisers['page_number'].to_i

    advertiser = advertisers['advertiser']
    advertiser = [advertiser] if advertiser.is_a?(Hash) # If we got exactly one result, put it in an array.
    advertiser.each { |item| @cj_objects << Advertiser.new(item) } if advertiser

    @cj_objects
  end

  def product_search(params)
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    if params.empty?
      raise ArgumentError, "You must provide at least one request parameter, for example, \"keywords\".\nSee https://cjcommunity.force.com/s/article/4777185."
    end

    params['website-id'] = @website_id

    @cj_objects = []

    response = self.class.get(WEB_SERVICE_URIS[:product_search], query: params, timeout: @timeout)
    products = extract_contents(response, 'products')

    @total_matched = products['total_matched'].to_i
    @records_returned = products['records_returned'].to_i
    @page_number = products['page_number'].to_i

    product = products['product']
    product = [product] if product.is_a?(Hash) # If we got exactly one result, put it in an array.
    product.each { |item| @cj_objects << Product.new(item) } if product

    @cj_objects
  end

  def link_search(params)
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    if params.empty?
      raise ArgumentError, "You must provide at least one request parameter, for example, \"keywords\".\nSee https://cjcommunity.force.com/s/article/4777180."
    end

    params['website-id'] = @website_id

    @cj_objects = []

    response = self.class.get(WEB_SERVICE_URIS[:link_search], query: params, timeout: @timeout)
    links = extract_contents(response, 'links')

    @total_matched = links['total_matched'].to_i
    @records_returned = links['records_returned'].to_i
    @page_number = links['page_number'].to_i

    link = links['link']
    link = [link] if link.is_a?(Hash) # If we got exactly one result, put it in an array.
    link.each { |item| @cj_objects << Link.new(item) } if link

    @cj_objects
  end

  def commissions(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = { 'date-type' => 'event' }.merge(params)

    @cj_objects = []

    response = self.class.get(WEB_SERVICE_URIS[:commissions], query: params)
    commissions = extract_contents(response, 'commissions')

    @total_matched = commissions['total_matched'].to_i
    @records_returned = commissions['records_returned'].to_i
    @page_number = commissions['page_number'].to_i

    commission = commissions['commission']
    commission = [commission] if commission.is_a?(Hash) # If we got exactly one result, put it in an array.
    commission.each { |item| @cj_objects << Commission.new(item) } if commission

    @cj_objects
  end

  def item_detail(original_action_ids)
    raise ArgumentError, "original_action_ids must be an Array; got #{original_action_ids.class} instead" unless original_action_ids.is_a?(Array)

    unless (1..50).cover?(original_action_ids.size)
      raise ArgumentError, "You must provide between 1 and 50 original action IDs.\nSee https://cjcommunity.force.com/s/article/4777175."
    end

    @cj_objects = []

    ids = original_action_ids.join(',')
    response = self.class.get(WEB_SERVICE_URIS[:item_detail] + ids, query: "original-action-id=#{ids}")
    @cj_objects = extract_contents(response, 'item_details')
    @cj_objects = [@cj_objects] if @cj_objects.is_a?(Hash) # If we got exactly one result, put it in an array.

    @cj_objects
  end

  def extract_contents(response, first_level, second_level = nil)
    cj_api = response['cj_api']

    raise ArgumentError, 'cj api missing from response' if cj_api.blank?

    error_message = cj_api['error_message'].presence

    raise ArgumentError, error_message if error_message

    return cj_api[first_level] if second_level.nil?
    cj_api[first_level][second_level]
  end

  # Turn a hash into an object where each key becomes an instance method.
  class CjObject
    def initialize(params)
      raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)
      raise ArgumentError, 'Expecting at least one parameter' if params.empty?

      # Create instance variables and attribute readers on the fly.
      # Credit:  http://listlibrary.net/ruby-talk/2004/03/00sGI1cD
      params.each do |key, val|
        raise ArgumentError, "key must be a String; got #{key.class} instead" unless key.is_a?(String)
        clean_key = clean_key_name(key)
        instance_variable_set("@#{clean_key}".intern, val)
        instance_eval %( class << self ; attr_reader #{clean_key.intern.inspect} ; end )
      end
    end

    def clean_key_name(name)
      name.strip.gsub(/\s/, '_')
    end
  end

  class Product < CjObject
  end

  class Advertiser < CjObject
  end

  class Link < CjObject
  end

  class Commission < CjObject
  end
end
