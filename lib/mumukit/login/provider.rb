module Mumukit::Login::Provider
  PROVIDERS = %w(
    developer
    saml
    cas
    auth0
    google
  )

  def self.from_env
    parse_login_provider(login_provider_string)
  end

  # This is a list of the default enabled login providers
  # It depends only on the current environment
  def self.default_enabled_providers
    case ENV['RACK_ENV'] || ENV['RAILS_ENV']
      when 'production'
        PROVIDERS - %w(developer)
      when 'test'
        PROVIDERS
      else
        %w(developer)
    end
  end

  # This is a list of the login providers enabled on the current instance of the platform
  # It is obtained from the environment, and if unset, it defaults to default_enabled_providers
  def self.enabled_providers
    if ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].blank?
      default_enabled_providers
    else
      ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].split ','
    end
  end

  # This is the default login provider used when it is not overriden in the organization's config
  # It is obtained from env, and defaults to the first of the current enabled providers
  # It should always be a provider within the enabled_providers list
  def self.login_provider_string
    if ENV['MUMUKI_LOGIN_PROVIDER'].blank?
      enabled_providers.first
    else
      ENV['MUMUKI_LOGIN_PROVIDER']
    end
  end

  def self.parse_login_provider(login_provider)
    if enabled_providers.include? login_provider
      "Mumukit::Login::Provider::#{login_provider.capitalize}".constantize.new
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
    @login_provider_object ||= login_provider.try { |it| Mumukit::Login::Provider.parse_login_provider it }
  end
end

require_relative './provider/base'

Mumukit::Login::Provider.enabled_providers.each do |it|
  require_relative "./provider/#{it}"
end
