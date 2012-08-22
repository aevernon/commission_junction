# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "commission_junction"
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Albert Vernon"]
  s.date = "2012-08-21"
  s.description = "Ruby wrapper for the Commission Junction web services APIs (REST)"
  s.email = "aev@vernon.nu"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "lib/commission_junction.rb",
    "test/commission_junction_test.rb",
    "test/test_helper.rb",
    "test/test_response.xml"
  ]
  s.homepage = "http://github.com/aevernon/commission_junction"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Commission Junction web services APIs (REST)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<crack>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<crack>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<crack>, [">= 0"])
  end
end

