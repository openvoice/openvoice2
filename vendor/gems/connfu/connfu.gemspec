# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "connfu/version"

Gem::Specification.new do |s|
  s.name        = "connfu"
  s.version     = Connfu::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Zhao Lu, James Mead, James Adam, Tom Wards, Kalvir Sandhu"]
  s.email       = %q{zlu@me.com}
  s.date        = %q{2011-05-06}
  s.homepage    = "http://github.com/zlu/play"
  s.summary     = %q{Ruby DSL for creating telephony applications}
  s.description = %q{Ruby DSL for creating telephony applications}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]

  s.rdoc_options = %w{--charset=UTF-8}
  s.extra_rdoc_files = %w{README.md}

  s.add_dependency("blather", "0.5.3")
  s.add_dependency("resque", "1.17.1")

  s.add_development_dependency("rake", "0.9.2")
  s.add_development_dependency("rspec", ">2.5.0")
  s.add_development_dependency("flog", "2.5.1")
  s.add_development_dependency("flay", "1.4.2")
  s.add_development_dependency("roodi", "2.1.0")
  s.add_development_dependency("reek", "1.2.8")
  s.add_development_dependency("Saikuro", "1.1.0")
  s.add_development_dependency("rcov", "0.9.9")
end
