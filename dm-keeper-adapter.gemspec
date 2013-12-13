# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dm-keeper-adapter/version"

Gem::Specification.new do |s|
  s.name        = "dm-keeper-adapter"
  s.version     = KeeperAdapter::VERSION

  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Klaus Kämpf"]
  s.email       = ["kkaempf@suse.de"]
  s.homepage    = "https://github.com/openSUSE/dm-keeper-adapter"
  s.summary     = %q{A datamapper adapter for FATE (aka keeper.novell.com)}
  s.description = %q{Use it in Ruby applications to access FATE}

  # get credentials from ~/.oscrc
  s.add_dependency("inifile", ["~> 0.4.1"])
  # parse xml response
  s.add_dependency("nokogiri", ["~> 1.5"])
  # DataMapper types
  s.add_dependency("dm-types", ["~> 1.2"])

  s.rubyforge_project = "dm-keeper-adapter"

  s.files         = `git ls-files`.split("\n")
  s.files.reject! { |fn| fn == '.gitignore' }
  s.extra_rdoc_files    = Dir['README*', 'TODO*', 'CHANGELOG*']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
