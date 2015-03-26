$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'mprofi_api_client'

Gem::Specification.new do |spec|
  spec.name 				= 'mprofi_api_client'
  spec.version      = MprofiApiClient::VERSION

  spec.summary      = 'MProfi API client library'
  spec.date         = '2015-03-05'
  spec.authors      = ['Materna Communications']
  
  spec.email        = 'biuro@materna.com.pl'
  spec.homepage     = 'https://github.com/materna/mprofi_api_client-ruby'
  spec.description  = spec.summary
  spec.license      = 'BSD'

  spec.required_ruby_version = '>= 1.9.3'
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'webmock'


  spec.files        = %w(Gemfile LICENSE mprofi_api_client.gemspec Rakefile README.md)
  spec.files        += Dir.glob('lib/**/*.rb')
end
