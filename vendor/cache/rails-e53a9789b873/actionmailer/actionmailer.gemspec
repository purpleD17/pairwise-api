# -*- encoding: utf-8 -*-
# stub: actionmailer 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "actionmailer".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-23"
  s.description = "Makes it trivial to test and deliver emails sent from a single service layer.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Service layer for easy email delivery and testing.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
  else
    s.add_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
  end
end
