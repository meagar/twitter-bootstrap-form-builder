# -*- encoding: utf-8 -*-
require File.expand_path('../lib/twitter-bootstrap-form-builder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matthew Eagar"]
  gem.email         = ["me@meagar.net"]
  gem.description   = "Build bootstrapped forms with next to no effort"
  gem.summary       = "Twitter Bootstrap FormBuilder"
  gem.homepage      = "http://meagar.github.com/twitter-bootstrap-form-builder/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "twitter-bootstrap-form-builder"
  gem.require_paths = ["lib"]
  gem.version       = MNE::TwitterBootstrapFormBuilder::VERSION

  gem.add_dependency 'dynamic_form', '~>1.1.4'
end
