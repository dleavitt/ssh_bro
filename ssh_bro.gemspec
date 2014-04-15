# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssh_bro/version'

Gem::Specification.new do |spec|
  spec.name          = "ssh_bro"
  spec.version       = SSHBro::VERSION
  spec.authors       = ["Daniel Leavitt"]
  spec.email         = ["daniel.leavitt@gmail.com"]
  spec.summary       = %q{Load SSH config from a Google Doc.}
  spec.description   = %q{Load SSH config from a Google Doc.}
  spec.homepage      = "https://github.com/dleavitt/ssh_bro"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency 'launchy'
  spec.add_dependency 'google-api-client'
  spec.add_dependency 'google_doc_seed', '~> 0.0.4'
end
