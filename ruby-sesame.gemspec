# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "ruby-sesame"
  s.version     = "0.2.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Paul Legato', "Till Schulte-Coerne"]
  s.email       = ["pjlegato at gmail dot com", "till.schulte-coerne at innoq dot com"]
  s.homepage    = "http://ruby-sesame.rubyforge.org"
  s.summary     = "Ruby OpenRDF.org interface"
  s.description = "A Ruby interface to OpenRDF.org\'s Sesame RDF triple store"

  s.required_rubygems_version = ">= 1.3.1"

  s.add_dependency "activesupport"
  s.add_dependency "json"
  s.add_dependency "net/http"

  s.files        = Dir.glob("{lib,spec}/**/*") + %w(COPYING README.txt ruby-sesame.gemspec)
  s.executables  = []
end
