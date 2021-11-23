# -*- encoding: utf-8 -*-
# stub: rails 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "rails".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-23"
  s.description = "Ruby on Rails is a full-stack web framework optimized for programmer happiness and sustainable productivity. It encourages beautiful code by favoring convention over configuration.".freeze
  s.email = "david@loudthinking.com".freeze
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Full-stack web application framework.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<activerecord>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<actionmailer>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<activeresource>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<railties>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<railslts-version>.freeze, ["= 2.3.18.37"])
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<activerecord>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<actionmailer>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<activeresource>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<railties>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<railslts-version>.freeze, ["= 2.3.18.37"])
  end
end
