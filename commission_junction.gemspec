# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'commission_junction/version'

Gem::Specification.new do |gem|
  gem.name          = 'commission_junction'
  gem.version       = CommissionJunction::VERSION
  gem.author        = 'Albert Vernon'
  gem.email         = 'aev@vernon.nu'
  gem.description   = 'Ruby wrapper for the Commission Junction web services APIs (REST)'
  gem.summary       = 'Commission Junction web services APIs (REST)'
  gem.homepage      = 'https://github.com/aevernon/commission_junction'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.add_dependency 'httparty', '~> 0.13'
  gem.add_development_dependency 'minitest', '> 0'
  gem.add_dependency 'ox', '~> 2.1'
  gem.license = 'BSD-3-Clause'
end
