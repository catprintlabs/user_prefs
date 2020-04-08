# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'user_prefs/version'

Gem::Specification.new do |spec|
  spec.name          = 'user_prefs'
  spec.version       = UserPrefs::VERSION
  spec.authors       = ['Adam George']
  spec.email         = ['adamgeorge.31@gmail.com']

  spec.summary       = 'Quick and easy model preferences for Rails.'
  spec.description   =
    'Add preferences to any Rails model easily by adding a text column and adding a couple macros'
  spec.homepage      = 'https://www.github.com/adamcreekroad/user_prefs'
  spec.license       = 'MIT'

  spec.files         =
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
