module Mumukit::Login::Provider
  def self.from_env
    parse_login_provider(login_provider_string).tap do |provider|
      puts "[Mumukit::Login] Using #{provider} as login provider"
    end
  end

  def self.login_provider_string
    if ENV['MUMUKI_LOGIN_PROVIDER'].blank? || ENV['RACK_ENV'] == 'test' || ENV['RAILS_ENV'] == 'test'
      'developer'
    else
      ENV['MUMUKI_LOGIN_PROVIDER']
    end
  end

  def self.parse_login_provider(login_provider)
    case login_provider
      when 'developer'
        Mumukit::Login::Provider::Developer.new
      when 'saml'
        Mumukit::Login::Provider::Saml.new
      when 'auth0'
        Mumukit::Login::Provider::Auth0.new
      else
        raise "Unknown login_provider `#{login_provider}`"
    end
  end
end

require_relative './provider/base'
require_relative './provider/saml'
require_relative './provider/auth0'
require_relative './provider/developer'