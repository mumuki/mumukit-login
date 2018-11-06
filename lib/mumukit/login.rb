require 'rack/request'
require 'addressable/uri'

require 'omniauth'
require 'omniauth-auth0'
require 'omniauth-saml'
require 'omniauth-cas'
require 'omniauth-google-oauth2'

require 'mumukit/core'
require 'mumukit/auth'
require 'mumukit/platform'

I18n.load_translations_path File.join(__dir__, '..', 'locales', '*.yml')

module Mumukit::Login
  extend Mumukit::Core::Configurable

  def self.defaults
    struct.tap do |config|
      config.logo_url = ENV['MUMUKI_LOGO_URL'] || "https://mumuki.io/static/logo.png"
      config.terms_url = ENV['MUMUKI_TERMS_URL'] || "https://mumuki.io/static/terms"
      config.mucookie_domain = ENV['MUMUKI_COOKIES_DOMAIN'] || ENV['MUMUKI_MUCOOKIE_DOMAIN']
      config.mucookie_secret_key = ENV['SECRET_KEY_BASE'] || ENV['MUMUKI_MUCOOKIE_SECRET_KEY']
      config.mucookie_secret_salt = ENV['MUMUKI_MUCOOKIE_SECRET_SALT'] || 'mucookie secret salt'
      config.mucookie_sign_salt = ENV['MUMUKI_MUCOOKIE_SIGN_KEY'] || 'mucookie sign salt'

      config.mucookie_duration = ENV['MUMUKI_MUCOOKIE_DURATION'].defaulting(14, &:to_i)

      config.provider = Mumukit::Login::Provider.from_env

      config.saml = struct base_url: ENV['MUMUKI_SAML_BASE_URL'],
                           idp_sso_target_url: ENV['MUMUKI_SAML_IDP_SSO_TARGET_URL'],
                           idp_slo_target_url: ENV['MUMUKI_SAML_IDP_SLO_TARGET_URL'],
                           translation_name: ENV['MUMUKI_SAML_TRANSLATION_NAME'] || 'name',
                           translation_email: ENV['MUMUKI_SAML_TRANSLATION_EMAIL'] || 'email',
                           translation_image: ENV['MUMUKI_SAML_TRANSLATION_IMAGE'] || 'image'
      config.cas = struct url: ENV['MUMUKI_CAS_URL'],
                          host: ENV['MUMUKI_CAS_HOST'],
                          ssl_certificate: ENV['MUMUKI_CAS_SSL_CERTIFICATE'],
                          disable_ssl_verification: ENV['MUMUKI_CAS_DISABLE_SSL_VERIFICATION'] == 'true'
      config.auth0 = struct client_id: ENV['MUMUKI_AUTH0_CLIENT_ID'],
                            client_secret: ENV['MUMUKI_AUTH0_CLIENT_SECRET'],
                            domain: ENV['MUMUKI_AUTH0_DOMAIN']
      config.google = struct client_id: ENV['MUMUKI_GOOGLE_CLIENT_ID'],
                             client_secret: ENV['MUMUKI_GOOGLE_CLIENT_SECRET']
    end
  end
end

require_relative './login/controller'
require_relative './login/shared_session'
require_relative './login/form'
require_relative './login/framework'
require_relative './login/mucookie'
require_relative './login/origin_redirector'
require_relative './login/profile'
require_relative './login/provider'
require_relative './login/settings'
require_relative './login/helpers'
require_relative './login/version'


module Mumukit::Login

  # Configures omniauth. This method typically configures
  # and sets the omniauth provider. Typical config should look like this
  #
  #   Rails.application.config.middleware.use OmniAuth::Builder do
  #    Mumukit::Login.configure_omniauth! self
  #   end
  #
  # @param [OmniAuth::Builder] omniauth
  #
  def self.configure_omniauth!(omniauth)
    Mumukit::Login::Provider.setup_providers! omniauth
  end

  def self.configure_login_routes!(native)
    web_framework.configure_login_routes! native
  end

  def self.configure_login_controller!(native)
    web_framework.configure_login_controller!(native)
  end

  def self.configure_controller!(native)
    web_framework.configure_controller! native
  end

  private

  def self.web_framework
    Mumukit::Platform.web_framework
  end

  def self.provider
    Mumukit::Platform::Organization.current.login_provider_object || config.provider
  end
end

Mumukit::Auth.configure do |config|
  config.clients.mucookie = {id: ENV['MUMUKI_MUCOOKIE_CLIENT_ID'],
                             secret: ENV['MUMUKI_MUCOOKIE_SECRET']}
end
