# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redlock_for_collection/version'

Gem::Specification.new do |spec|
  spec.name          = 'redlock_for_collection'
  spec.version       = RedlockForCollection::VERSION
  spec.authors       = ['CoolElvis']
  spec.email         = ['elvisplus2@gmail.com']

  spec.summary       = %q{This is just a Redlock wrapper for collection of objects.}
  spec.description   = %q{This is just a Redlock wrapper for collection of objects. Also it used a connection pool for restrict the redis connections.}
  spec.homepage      = 'https://github.com/CoolElvis/redlock_for_collection'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'connection_pool', '~> 2.2.0'
  spec.add_development_dependency 'redlock', '~> 0.1.1'
end
