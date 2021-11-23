# -*- encoding: utf-8 -*-
# stub: railslts-version 2.3.18.37 ruby lib

Gem::Specification.new do |s|
  s.name = "railslts-version".freeze
  s.version = "2.3.18.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Arne Hartherz".freeze]
  s.date = "2021-11-23"
  s.description = "Note that this gem will neither install nor upgrade Rails LTS for you. Visit https://railslts.com/ to find out more about Rails LTS.".freeze
  s.email = ["arne.hartherz@makandra.de".freeze]
  s.files = ["Rakefile".freeze, "lib/railslts-version.rb".freeze, "railslts-version.gemspec".freeze]
  s.homepage = "https://railslts.com/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Gem to track your current Rails LTS version.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
