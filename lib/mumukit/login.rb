require 'rack/request'
require 'addressable/uri'

require 'omniauth'
require 'omniauth-auth0'
require 'omniauth-saml'

require 'mumukit/core'

require_relative './login/version'

module Mumukit::Login
  def self.configure
    @config ||= defaults
    yield @config
  end

  def self.defaults
    struct.tap do |config|
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
    framework.configure_login_routes! native
  end

  def self.configure_login_controller!(native)
    framework.configure_login_controller!(native)
  end

  def self.configure_controller!(native)
    framework.configure_controller! native
  end

  private

  def self.framework
    Mumukit::Login.config.framework
  end

  def self.provider
    Mumukit::Login.config.provider
  end
end

module Mumukit::Login::LoginControllerHelpers

  def login
    origin_redirector.save_location!
    login_provider.request_authentication! mumukit_controller, login_settings
  end

  def callback
    profile = Mumukit::Login::Profile.from_omniauth(env['omniauth.auth'])
    user = Mumukit::Login.config.user_class.for_profile profile
    save_session_user_uid! user
    origin_redirector.redirect!
  end

  def destroy
    destroy_session_user_uid!
    mumukit_controller.redirect! login_provider.logout_redirection_path
  end

  private

  # default
  def destroy_session_user_uid!
    mumukit_controller.session[:user_uid] = nil
  end

  # default
  def save_session_user_uid!(user)
    mumukit_controller.session[:user_uid] = user.uid
  end
end

module Mumukit::Login::AuthenticationHelpers

  def authenticate!
    login_form.show! unless current_user?
  end

  def current_user?
    current_user_uid.present?
  end

  def current_user
    @current_user ||= Mumukit::Login.config.user_class.find_by_uid!(current_user_uid) if current_user?
  end

  private

  # default
  def current_user_uid
    mumukit_controller.session[:user_uid]
  end

  # default
  def login_settings
    Mumukit::Login::Settings.new
  end

  def mumukit_controller
    @mumukit_controller ||= Mumukit::Login::Controller.new login_framework, self
  end

  def login_form
    @login_builder ||= Mumukit::Login::Form.new login_provider, mumukit_controller, login_settings
  end

  def origin_redirector
    @after_login_redirector ||= Mumukit::Login::OriginRedirector.new mumukit_controller
  end

  def login_framework
    Mumukit::Login.config.framework
  end

  def login_provider
    Mumukit::Login.config.provider
  end
end

require_relative './login/controller'
require_relative './login/form'
require_relative './login/framework'
require_relative './login/origin_redirector'
require_relative './login/profile'
require_relative './login/provider'
require_relative './login/settings'
require_relative './login/version'
