require 'commission_junction/version'
require 'httparty'

# Silence peer certificate warnings from Net::HTTP.
# Credit:  http://www.5dollarwhitebox.org/drupal/node/64
class Net::HTTP
  alias_method :old_initialize, :initialize

  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end

# Interact with CJ web services.
class CommissionJunction
  include HTTParty
  format(:xml)
  #debug_output $stderr

  attr_reader :total_matched,
              :records_returned,
              :page_number,
              :cj_objects

  WEB_SERVICE_URIS =
  {
    :product_search    => 'https://product-search.api.cj.com/v2/product-search',
    :advertiser_lookup => 'https://advertiser-lookup.api.cj.com/v3/advertiser-lookup',
    :categories        => 'https://support-services.api.cj.com/v2/categories',
    :commissions       => 'https://commission-detail.api.cj.com/v3/commissions'
  }

  def initialize(developer_key, website_id, timeout = 10)
    raise ArgumentError, "developer_key must be a String; got #{developer_key.class} instead" unless developer_key.is_a?(String)
    raise ArgumentError, "You must supply your developer key.\nSee https://api.cj.com/sign_up.cj" unless developer_key.length > 0

    website_id = website_id.to_s
    raise ArgumentError, "You must supply your website ID.\nSee cj.com > Account > Web site Settings > PID" unless website_id.length > 0
    @website_id = website_id

    raise ArgumentError, "timeout must be a Fixnum; got #{timeout.class} instead" unless timeout.is_a?(Fixnum)
    raise ArgumentError, "timeout must be > 0; got #{timeout} instead" unless timeout > 0
    @timeout = timeout

    self_class = self.class
    self_class.headers('authorization' => developer_key)
  end

  def categories(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = {'locale' => 'en'}.merge(params)

    response = self.class.get(WEB_SERVICE_URIS[:categories], :query => params, :timeout => @timeout)

    cj_api = response['cj_api']
    error_message = cj_api['error_message']

    raise ArgumentError, error_message if error_message

    @categories = cj_api['categories']['category']
  end

  def advertiser_lookup(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = {'advertiser-ids' => 'joined'}.merge(params)

    @cj_objects = []

    begin
      response = self.class.get(WEB_SERVICE_URIS[:advertiser_lookup], :query => params)
      cj_api = response['cj_api']
      error_message = cj_api['error_message']

      raise ArgumentError, error_message if error_message

      advertisers = cj_api['advertisers']

      @total_matched = advertisers['total_matched'].to_i
      @records_returned = advertisers['records_returned'].to_i
      @page_number = advertisers['page_number'].to_i

      advertiser = advertisers['advertiser']
      advertiser = [advertiser] if advertiser.is_a?(Hash) # If we got exactly one result, put it in an array.
      advertiser.each { |item| @cj_objects << Advertiser.new(item) } if advertiser
    rescue Timeout::Error
      @total_matched = @records_returned = @page_number = 0
    end

    @cj_objects
  end

  def product_search(params)
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    unless params.size > 0
      raise ArgumentError, "You must provide at least one request parameter, for example, \"keywords\".\nSee http://help.cj.com/en/web_services/product_catalog_search_service_rest.htm"
    end

    params['website-id'] = @website_id

    @cj_objects = []

    begin
      response = self.class.get(WEB_SERVICE_URIS[:product_search], :query => params, :timeout => @timeout)

      cj_api = response['cj_api']
      error_message = cj_api['error_message']

      raise ArgumentError, error_message if error_message

      products = cj_api['products']

      @total_matched = products['total_matched'].to_i
      @records_returned = products['records_returned'].to_i
      @page_number = products['page_number'].to_i

      product = products['product']
      product = [product] if product.is_a?(Hash) # If we got exactly one result, put it in an array.
      product.each { |item| @cj_objects << Product.new(item) } if product
    rescue Timeout::Error
      @total_matched = @records_returned = @page_number = 0
    end

    @cj_objects
  end

  def commissions(params = {})
    raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)

    params = {'date-type' => 'event'}.merge(params)

    @cj_objects = []

    begin
      response = self.class.get(WEB_SERVICE_URIS[:commissions], :query => params)
      cj_api = response['cj_api']
      error_message = cj_api['error_message']

      raise ArgumentError, error_message if error_message

      commissions = cj_api['commissions']

      @total_matched = commissions['total_matched'].to_i
      @records_returned = commissions['records_returned'].to_i
      @page_number = commissions['page_number'].to_i

      commission = commissions['commission']
      commission = [commission] if commission.is_a?(Hash) # If we got exactly one result, put it in an array.
      commission.each { |item| @cj_objects << Commission.new(item) } if commission
    rescue Timeout::Error
      @total_matched = @records_returned = @page_number = 0
    end

    @cj_objects
  end

  class CjObject
    def initialize(params)
      raise ArgumentError, "params must be a Hash; got #{params.class} instead" unless params.is_a?(Hash)
      raise ArgumentError, 'Expecting at least one parameter' unless params.size > 0

      # Create instance variables and attribute readers on the fly.
      # Credit:  http://listlibrary.net/ruby-talk/2004/03/00sGI1cD
      params.each do |key, val|
        raise ArgumentError, "key must be a String; got #{key.class} instead" unless key.is_a?(String)
        instance_variable_set("@#{key}".intern, val)
        instance_eval %Q{ class << self ; attr_reader #{key.intern.inspect} ; end }
      end
    end
  end

  class Product < CjObject
  end

  class Advertiser < CjObject
  end

  class Commission < CjObject
  end
end
