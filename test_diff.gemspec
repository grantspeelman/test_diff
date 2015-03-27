# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_diff/version'

Gem::Specification.new do |spec|
  spec.name          = 'test_diff'
  spec.version       = TestDiff::VERSION
  spec.authors       = ['Grant Speelman']
  spec.email         = ['grant.speelman@ubxd.com']

  spec.summary       = 'Gem that attempts to find the tests that are required to run for the changes you have made.'
  spec.description   = 'Gem that attempts to find the tests that are required to run for the changes you have made.'
  spec.homepage      = 'https://github.com/grantspeelman/test_diff'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/^exe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'minitest', '>= 0.8.0'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
