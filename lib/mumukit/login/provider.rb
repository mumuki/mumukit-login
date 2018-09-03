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

  def self.default_enabled_providers
    case ENV['RAILS_ENV'] || ENV['RACK_ENV']
      when 'production'
        %w(auth0 saml google)
      when 'test'
        PROVIDERS
      else
        %w(developer)
    end
  end

  def self.enabled_providers
    if ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].blank?
      default_enabled_providers
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

  def self.parse_login_provider(login_provider, provider_settings = {})
    if enabled_providers.include? login_provider
      "Mumukit::Login::Provider::#{login_provider.capitalize}".constantize.new provider_settings
    else
      raise "Unknown login_provider `#{login_provider}`"
    end
  end

  def self.setup_providers!(omniauth)
    enabled_providers.each { |it| parse_login_provider(it).configure_omniauth!(omniauth) }
  end
end

module Mumukit::Platform::Organization::Helpers
  def login_provider_object
    @login_provider_object ||= login_provider.try { |it| Mumukit::Login::Provider.parse_login_provider it, provider_settings }
  end
end

require_relative './provider/base'

Mumukit::Login::Provider.enabled_providers.each do |it|
  require_relative "./provider/#{it}"
end
