# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploy-recipes/version'

Gem::Specification.new do |gem|
  gem.name          = "deploy-recipes"
  gem.version       = Deploy::Recipes::VERSION
  gem.authors       = ["liuhui"]
  gem.email         = ["liuhui998@gmail.com"]
  gem.description   = %q{ Cap recipes }
  gem.summary       = %q{ nginx unicorn}
  gem.homepage      = "https://github.com/liuhui998/deploy-recipes"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
