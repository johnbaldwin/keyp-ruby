# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keyp/version'

Gem::Specification.new do |spec|
  spec.name          = "keyp"
  spec.version       = Keyp::VERSION
  spec.authors       = ["John Baldwin"]
  spec.email         = ["jlbaldwin@gmail.com"]
  spec.summary       = %q{Manage environment/machine specific key:value pairs for your Ruby application.}
  spec.description   = %q{Keyp is a key:value manager with a command line tool and library API to make managing authentication and configuration information easier.}
  spec.homepage      = "https://github.com/johnbaldwin/keyp-ruby"
  spec.license       = "Apache v2"

  spec.files         = `git ls-files`.split($/)
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'gli',     '~> 2.9'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake',    '~> 10.1'
  #spec.add_development_dependency 'gli',     '~> 2.9'
  spec.add_development_dependency 'rspec',   '~> 2.14'
  spec.executables = 'keyp'

end
