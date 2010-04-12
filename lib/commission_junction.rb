require 'httparty'

# Interact with CJ web services.
class CommissionJunction
  include HTTParty
  format(:xml)
  #debug_output $stderr

  attr_reader :total_matched,
              :records_returned,
              :page_number,
              :products

  WEB_SERVICE_URIS =
  {
    :product_search => 'https://product-search.api.cj.com/v2/product-search'
  }

  def initialize(developer_key, website_id)
    raise ArgumentError, 'developer_key must be a String' unless developer_key.is_a?(String)

    unless developer_key.length > 0
      raise ArgumentError, "You must supply your developer key.\nSee https://api.cj.com/sign_up.cj"
    end

    website_id = website_id.to_s

    unless website_id.length > 0
      raise ArgumentError, "You must supply your website ID.\nSee cj.com > Account > Web site Settings > PID"
    end

    self.class.headers('authorization' => developer_key)
    self.class.default_params('website-id' => website_id)
  end

  def product_search(params)
    raise ArgumentError, 'params must be a Hash' unless params.is_a?(Hash)

    unless params.size > 0
      raise ArgumentError, "You must provide at least one request parameter, for example, \"keywords\".\nSee http://help.cj.com/en/web_services/product_catalog_search_service_rest.htm"
    end

    if caller_method_name == 'test_product_search_with_keywords_non_live'
      response = Crack::XML.parse(IO.read('test/test_response.xml'))
    else
      response = self.class.get(WEB_SERVICE_URIS[:product_search], :query => params)
    end

    cj_api = response['cj_api']
    error_message = cj_api['error_message']

    if error_message && error_message[0, 17] == 'Not Authenticated'
      raise ArgumentError, "Commission Junction cannot authenticate your developer key.\nSee https://api.cj.com/sign_up.cj"
    elsif error_message
      raise ArgumentError, error_message
    end

    products = cj_api['products']

    @total_matched = products['total_matched'].to_i
    @records_returned = products['records_returned'].to_i
    @page_number = products['page_number'].to_i
    @products = []
    products['product'].each { |product| @products << Product.new(product) }
    @products
  end

  # Represent products from a catalog search.
  class Product
    def initialize(params)
      raise ArgumentError, 'params must be a Hash' unless params.is_a?(Hash)
      raise ArgumentError, 'Expecting at least one parameter' unless params.size > 0

      # Create instance variables and attribute readers on the fly.
      # Credit:  http://listlibrary.net/ruby-talk/2004/03/00sGI1cD
      params.each do |key, val|
        raise ArgumentError, 'key must be a String' unless key.is_a?(String)
        instance_variable_set("@#{key}".intern, val)
        instance_eval %Q{ class << self ; attr_reader #{key.intern.inspect} ; end }
      end
    end
  end

  private

  # Credit:  http://snippets.dzone.com/posts/show/2787
  def caller_method_name
    parse_caller(caller(2).first).last
  end

  def parse_caller(at)
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at
      last_match = Regexp.last_match
      file = last_match[1]
      line = last_match[2].to_i
      method = last_match[3]
      [file, line, method]
    end
  end
end
