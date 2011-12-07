# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tire-mock_client/version"

Gem::Specification.new do |s|
  s.name        = "tire-mock_client"
  s.version     = Tire::Mockclient::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Amos King"]
  s.email       = ["amos.l.king@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Faked out Tire client.}
  s.description = %q{Fake client for Tire to allows tests without running elastic search.}

  s.rubyforge_project = "tire-mock_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ['README']
  s.add_dependency('tire', '>= 0.3.11')
  s.add_dependency('activesupport')
  
  s.add_development_dependency('rspec')
end
