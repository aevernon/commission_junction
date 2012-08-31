commission_junction
===================

Ruby wrapper for the Commission Junction web services APIs (REST)

Installation
------------

`sudo gem install commission_junction`

Example
-------

```ruby
require 'rubygems'
require 'commission_junction'

# See https://api.cj.com/sign_up.cj
DEVELOPER_KEY = '????????'

# See cj.com > Account > Web site Settings > PID
WEBSITE_ID = '????????'

cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

# See http://help.cj.com/en/web_services/product_catalog_search_service_rest.htm
# for the list of request and response parameters.
cj.product_search('keywords' => '+blue +jeans',
		 'advertiser-ids' => 'joined',
		 'serviceable-area' => 'us',
		 'currency' => 'usd',
		 'records-per-page' => '5').each do |product|
 puts product.name
 puts product.price
 puts product.image_url
 puts ''
end

# See http://help.cj.com/en/web_services/advertiser_lookup_service_rest.htm
# for the list of request and response parameters.
cj.advertiser_lookup('keywords' => '+used +books',
		    'advertiser-ids' => 'joined',
		    'records-per-page' => '5').each do |advertiser|
 puts advertiser.advertiser_name
 puts advertiser.network_rank
 puts advertiser.program_url
 puts ''
end

# See http://help.cj.com/en/web_services/support_services_rest.htm
# for the list of request and response parameters.
puts cj.categories

# See http://help.cj.com/en/web_services/Commission_Detail_Service.htm
# for the list of request and response parameters.
cj.commissions.each do |commission|
 puts commission.action_type
 puts commission.aid
 puts commission.commission_id
 puts commission.event_date
 puts commission.advertiser_name
 puts commission.commission_amount
 puts commission.sid
 puts ''
end
```

Dependencies
------------

* httparty

Contributing
------------

* Feel free to file a bug report or enhancement request, even if you don't have time to submit a patch.
* Please try to include a test for any patch you submit. If you don't include a test, I'll have to write one, and it'll take longer to get your code in.
* Remember to send me a pull request.

Authors
-------

* [Albert Vernon](https://github.com/aevernon)
* [C.J. Sanders](https://github.com/cjsanders)
* [Michael Nutt](https://github.com/mnutt)
* [Jean-Sebastien Boulanger](https://github.com/jsboulanger)

Copyright
---------

Copyright (c) 2012 Albert Vernon. See LICENSE for details.
