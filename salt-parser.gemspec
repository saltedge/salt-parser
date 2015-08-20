# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "salt-parser/version"

Gem::Specification.new do |s|
  s.name        = "salt-parser"
  s.version     = SaltParser::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO"]
  s.email       = ["todo@example.com"]
  s.homepage    = "http://example.com"
  s.license     = "Proprietary"
  s.summary     = "Gem for parsing OFX, HBCI, QIF and SWIFT formats."
  s.description = <<-TXT
    Gem for parsing OFX, HBCI, QIF and SWIFT formats.
    Usage:
    ```OFX("v102.ofx") do |ofx|
      p ofx
    end```
TXT
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |file| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "nokogiri"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency "rake"
  s.add_development_dependency "pry-byebug"
end
