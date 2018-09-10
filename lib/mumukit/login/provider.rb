module Mumukit::Login::Provider
  PROVIDERS = %w(
    developer
    saml
    auth0
    google
  )

  def self.from_env
    parse_login_provider(login_provider_string)
  end

  def self.enabled_providers
    if ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].blank?
      PROVIDERS
    else
      ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].split ', '
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
      when 'google'
        Mumukit::Login::Provider::Google.new
      else
        raise "Unknown login_provider `#{login_provider}`"
    end
  end

  def self.setup_providers!(omniauth)
    enabled_providers.each { |it| parse_login_provider(it).configure_omniauth!(omniauth) }
  end
end

require_relative './provider/base'
require_relative './provider/saml'
require_relative './provider/auth0'
require_relative './provider/developer'
require_relative './provider/google'
