lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rvm/capistrano/version'
require 'yaml'

Gem::Specification.new do |spec|
  spec.name        = 'rvm-capistrano'
  spec.version     = ::RVM::Capistrano::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Wayne E. Seguin', 'Michal Papis']
  spec.email       = ['wayneeseguin@gmail.com','mpapis@gmail.com']
  spec.homepage    = 'https://github.com/wayneeseguin/rvm-capistrano'
  spec.summary     =
  spec.description = 'RVM / Capistrano Integration Gem'
  spec.license     = 'MIT'

  spec.add_dependency 'capistrano', '~>2.15.4'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'capistrano-spec'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'

  spec.require_path = 'lib'
  spec.files        = YAML.load_file('Manifest.yml')
  spec.test_files   = Dir.glob('spec/**/*.rb')
end
