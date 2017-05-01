require 'rack/request'
require 'addressable/uri'

require 'omniauth'
require 'omniauth-auth0'
require 'omniauth-saml'

require 'mumukit/core'
require 'mumukit/auth'
require 'mumukit/platform'

module Mumukit::Login
  def self.configure
    @config ||= defaults
    yield @config
  end

  def self.defaults
    struct.tap do |config|
      config.logo_url = ENV['MUMUKI_LOGO_URL'] || "https://mumuki.io/static/logo.png"
      config.mucookie_domain = ENV['MUMUKI_COOKIES_DOMAIN'] || ENV['MUMUKI_MUCOOKIE_DOMAIN']
      config.mucookie_secret_key = ENV['SECRET_KEY_BASE'] || ENV['MUMUKI_MUCOOKIE_SECRET_KEY']
      config.mucookie_secret_salt = ENV['MUMUKI_MUCOOKIE_SECRET_SALT'] || 'mucookie secret salt'
      config.mucookie_sign_salt = ENV['MUMUKI_MUCOOKIE_SIGN_KEY'] || 'mucookie sign salt'

      config.provider = Mumukit::Login::Provider.from_env
      config.saml = struct base_url: ENV['MUMUKI_SAML_BASE_URL'],
                           idp_sso_target_url: ENV['MUMUKI_SAML_IDP_SSO_TARGET_URL'],
                           idp_slo_target_url: ENV['MUMUKI_SAML_IDP_SLO_TARGET_URL'],
                           translation_name: ENV['MUMUKI_SAML_TRANSLATION_NAME'] || 'name',
                           translation_email: ENV['MUMUKI_SAML_TRANSLATION_EMAIL'] || 'email',
                           translation_image: ENV['MUMUKI_SAML_TRANSLATION_IMAGE'] || 'image'
      config.auth0 = struct client_id: ENV['MUMUKI_AUTH0_CLIENT_ID'],
                            client_secret: ENV['MUMUKI_AUTH0_CLIENT_SECRET'],
                            domain: ENV['MUMUKI_AUTH0_DOMAIN']
    end
  end

  def self.config
    @config
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
    provider.configure_omniauth! omniauth
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
    Mumukit::Login.config.provider
  end
end

Mumukit::Auth.configure do |config|
  config.clients.mucookie = {id: ENV['MUMUKI_MUCOOKIE_CLIENT_ID'],
                             secret: ENV['MUMUKI_MUCOOKIE_SECRET']}
end