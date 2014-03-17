# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keyp/version'

Gem::Specification.new do |spec|
  spec.name          = "keyp"
  spec.version       = Keyp::VERSION
  spec.authors       = ["John Baldwin"]
  spec.email         = ["jlbaldwin@gmail.com"]
  spec.summary       = %q{Manage environment/machine specific key/value pairs for your Ruby application.}
  spec.description   = spec.summary=
  spec.homepage      = "https://github.com/johnbaldwin/keyp"
  spec.license       = "Apache v2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "thor"

end
