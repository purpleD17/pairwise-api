# -*- encoding: utf-8 -*-
# stub: railties 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "railties".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-23"
  s.description = "Rails internals: application bootup, plugins, generators, and rake tasks.".freeze
  s.email = "david@loudthinking.com".freeze
  s.executables = ["rails".freeze]
  s.files = ["bin/rails".freeze]
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rdoc_options = ["--exclude".freeze, ".".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Tools for creating, working with, and running Rails applications.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rake>.freeze, [">= 0.8.3", "< 11"])
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_runtime_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0.8.3", "< 11"])
    s.add_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
    s.add_dependency(%q<actionpack>.freeze, ["= 2.3.18.37"])
  end
end
