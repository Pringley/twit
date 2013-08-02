# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twit/version'

Gem::Specification.new do |spec|
  spec.name          = "twit"
  spec.version       = Twit::VERSION
  spec.authors       = ["Ben Pringle"]
  spec.email         = ["ben.pringle@gmail.com"]
  spec.description   = %q{Create a simpler abstraction over the git command}
  spec.summary       = %q{Simplified git wrapper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
