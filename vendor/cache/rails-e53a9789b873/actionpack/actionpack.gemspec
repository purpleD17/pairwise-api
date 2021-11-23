# -*- encoding: utf-8 -*-
# stub: actionpack 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "actionpack".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-23"
  s.description = "Eases web-request routing, handling, and response as a half-way front, half-way page controller. Implemented with specific emphasis on enabling easy unit/integration testing that doesn't require a browser.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Web-flow and rendering framework putting the VC in MVC.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<rack>.freeze, ["< 1.5"])
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<rack>.freeze, ["< 1.5"])
  end
end
