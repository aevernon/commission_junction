require 'httparty'

class CommissionJunction
  include HTTParty
  format(:xml)
  # debug_output $stderr

  attr_reader :total_matched, :records_returned, :page_number

  WEB_SERVICE_URIS =
  {
    :product_search => 'https://product-search.api.cj.com/v2/product-search'
  }

  def initialize(developer_key)
    raise ArgumentError, 'developer_key must be a string' unless developer_key.is_a?(String)

    unless developer_key.length > 0
      raise ArgumentError, "You must supply your developer key.\nSee https://api.cj.com/sign_up.cj"
    end

    self.class.headers('authorization' => developer_key)
  end

  def product_search(params)
    raise ArgumentError, 'params must be a hash' unless params.is_a?(Hash)

    unless params.size > 0
      raise ArgumentError, "You must provide at least one request parameter, for example, \"website-id\" or \"keywords\".\nSee http://help.cj.com/en/web_services/product_catalog_search_service_rest.htm"
    end

    response = self.class.get(WEB_SERVICE_URIS[:product_search], :query => params)

    if response['cj_api']['error_message'] && response['cj_api']['error_message'][0, 17] == 'Not Authenticated'
      raise ArgumentError, "Commission Junction cannot authenticate your developer key.\nSee https://api.cj.com/sign_up.cj"
    end

    products = response['cj_api']['products']

    @total_matched = products['total_matched'].to_i
    @records_returned = products['records_returned'].to_i
    @page_number = products['page_number'].to_i
  end
end
