# -*- encoding: utf-8 -*-
# stub: activeresource 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "activeresource".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2021-11-23"
  s.description = "Wraps web resources in model classes that can be manipulated through XML over REST.".freeze
  s.email = "david@loudthinking.com".freeze
  s.extra_rdoc_files = ["README".freeze]
  s.files = ["README".freeze]
  s.homepage = "http://www.rubyonrails.org".freeze
  s.rdoc_options = ["--main".freeze, "README".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Think Active Record for web resources.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 2.3.18.37"])
  end
end
