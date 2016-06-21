# commission_junction

Ruby wrapper for the Commission Junction web services APIs (REST)

See https://cjcommunity.force.com/s/article/4777058.

[![Gem Version](https://badge.fury.io/rb/commission_junction.png)](http://badge.fury.io/rb/commission_junction)

## Installation

Add this line to your application's Gemfile:

`gem 'commission_junction'`

And then execute

`bundle`

Or install it yourself as:

`gem install commission_junction`

## Example

```ruby
require 'rubygems'
require 'commission_junction'

# See https://api.cj.com/sign_up.cj.
DEVELOPER_KEY = '????????'

# See cj.com > Account > Websites.
WEBSITE_ID = '????????'

cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

# See https://cjcommunity.force.com/s/article/4777185
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

# See https://cjcommunity.force.com/s/article/4777195
# for the list of request and response parameters.
cj.advertiser_lookup('keywords' => '+used +books',
                     'advertiser-ids' => 'joined',
                     'records-per-page' => '5').each do |advertiser|
  puts advertiser.advertiser_name
  puts advertiser.network_rank
  puts advertiser.program_url
  puts ''
end

# See https://cjcommunity.force.com/s/article/4777180
# for the list of request and response parameters.
cj.link_search('keywords' => '+used +books',
               'advertiser-ids' => 'joined',
               'records-per-page' => '5').each do |link|
  puts link.link_id
  puts link.link_name
  puts link.link_code_html
  puts link.sale_commission
  puts ''
end

# See https://cjcommunity.force.com/s/article/4777190
# for the list of request and response parameters.
puts cj.categories

# See https://cjcommunity.force.com/s/article/4777175
# for the list of request and response parameters.
ids = []

cj.commissions.each do |commission|
  ids << commission.original_action_id
  puts commission.action_type
  puts commission.aid
  puts commission.commission_id
  puts commission.event_date
  puts commission.advertiser_name
  puts commission.commission_amount
  puts commission.sid
  puts ''
end

# Each commission comes from the sale of one or more items.
# Commissions and their items are linked by original_action_id.
cj.item_detail(ids[0, 50]).each do |item_detail|
  puts item_detail['original_action_id']

  items = item_detail['item']
  # If there is exactly one item, put it in an array.
  items = [items] if items.is_a?(Hash)

  items.each do |item|
    puts item['sku']
    puts item['quantity']
    puts item['posting_date']
    puts item['commission_id']
    puts item['sale_amount']
    puts item['discount']
    puts item['publisher_commission']
  end if items
end
```

## Dependencies

* httparty
* ox

## Contributing

* Feel free to file a bug report or enhancement request, even if you don't have time to submit a patch.
* Please try to include a test for any patch you submit. If you don't include a test, I'll have to write one, and it'll take longer to get your code in.
* Remember to send me a pull request.

## Authors

* [Albert Vernon](https://github.com/aevernon)
* [C.J. Sanders](https://github.com/cjsanders)
* [Michael Nutt](https://github.com/mnutt)
* [Jean-Sebastien Boulanger](https://github.com/jsboulanger)
* [luckyjazzbo](https://github.com/luckyjazzbo)
* [samsaradog](https://github.com/samsaradog)

## Copyright

Copyright (c) 2012 Albert Vernon. See LICENSE for details.
