# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mumukit/login/version'

Gem::Specification.new do |spec|
  spec.name          = 'mumukit-login'
  spec.version       = Mumukit::Login::VERSION
  spec.authors       = ['Franco Leonardo Bulgarelli']
  spec.email         = ['franco@mumuki.org']
  spec.summary       = 'Library for login mumuki requests'
  spec.homepage      = 'http://github.com/mumuki/mumukit-login'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/**']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'rack', '>= 2.1'
  spec.add_dependency 'jwt', '~> 1.5'
  spec.add_dependency 'addressable'
  spec.add_dependency 'omniauth', '~> 1.2'
  spec.add_dependency 'omniauth-auth0', '~> 1.1'
  spec.add_dependency 'omniauth-saml', '~> 1.6'
  spec.add_dependency 'omniauth-cas', '~> 1.1'
  spec.add_dependency 'omniauth-google-oauth2', '~> 0.5'
  spec.add_dependency 'mumukit-core', '~> 1.8'
  spec.add_dependency 'mumukit-auth', '~> 7.0'
  spec.add_dependency 'mumukit-platform', '~> 7.0'
  spec.add_dependency 'actionpack', '>= 6.0'

  spec.required_ruby_version = '>= 3.0'
end
