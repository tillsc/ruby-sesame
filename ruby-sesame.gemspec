# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "ruby-sesame"
  s.version     = "0.2.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Paul Legato', "Till Schulte-Coerne"]
  s.email       = ["pjlegato at gmail dot com", "till.schulte-coerne at innoq dot com"]
  s.homepage    = "http://ruby-sesame.rubyforge.org"
  s.summary     = "A Ruby library to interact with the Sesame RDF framework."
  s.description = "A Ruby library to interact with OpenRDF.org's Sesame triplestore via its REST interface."

  s.required_rubygems_version = ">= 1.3.1"

  s.add_dependency "activesupport"
  s.add_dependency "json"

  s.files        = Dir.glob("{lib,spec}/**/*") + %w(COPYING README.txt ruby-sesame.gemspec)
  s.executables  = []
end
