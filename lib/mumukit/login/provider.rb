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

  def self.default_enabled_providers                  # This is a list of the default enabled login providers
    case ENV['RACK_ENV'] || ENV['RAILS_ENV']          # It depends only on the current environment
      when 'production'
        PROVIDERS - %w(developer)
      when 'test'
        PROVIDERS
      else
        %w(developer)
    end
  end

  def self.enabled_providers                          # This is a list of the login providers enabled on the current instance of the platform
    if ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].blank?   # It is obtained from the environment, and if unset, it defaults to default_enabled_providers
      default_enabled_providers
    else
      ENV['MUMUKI_ENABLED_LOGIN_PROVIDERS'].split ','
    end
  end

  def self.login_provider_string                      # This is the default login provider used when it is not overriden in the organization's config
    if ENV['MUMUKI_LOGIN_PROVIDER'].blank?            # It is obtained from env, and defaults to the first of the current enabled providers
      enabled_providers.first                         # It should always be a provider within the enabled_providers list
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
