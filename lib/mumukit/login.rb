require_relative './login/version'

require 'addressable/uri'

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

class Mumukit::Login::Provider::Base
  def name
    @name ||= self.class.name.demodulize.downcase
  end

  required :configure_omniauth!

  def request_authentication!(controller, _login_settings)
    controller.redirect! auth_path
  end

  def configure_rails_forgery_protection!(action_controller)
    action_controller.protect_from_forgery with: :exception
  end

  def login_path(controller)
    "/login?origin=#{controller.request.path}"
  end

  def auth_path
    "/auth/#{name}"
  end

  def callback_path
    "/auth/#{name}/callback"
  end

  def logout_redirection_path
    '/'
  end

  def button_html(controller, title, clazz)
    %Q{<a class="#{clazz}" href="#{login_path(controller)}">#{title}</a>}
  end

  def footer_html(*)
    nil
  end

  def header_html(*)
    nil
  end
end

class Mumukit::Login::Provider::Saml < Mumukit::Login::Provider::Base
  def saml_config
    Mumukit::Login.config.saml
  end

  def configure_omniauth!(omniauth)
    omniauth.provider :saml,
                      # TODO: change the :assertion_consumer_service_url, the :issuer and the :slo_default_relay_state:
                      # =>  1. we can not call any Organization method since there is none instantiated yet and
                      # =>  2. we must use the absolut path to generate the right SAML metadata to set up the federation with the IdP
                      assertion_consumer_service_url: "#{saml_config.base_url}#{callback_path}",
                      single_logout_service_url: "#{saml_config.base_url}#{auth_path}/slo",
                      issuer: "#{saml_config.base_url}#{auth_path}",
                      idp_sso_target_url: saml_config.idp_sso_target_url,
                      idp_slo_target_url: saml_config.idp_slo_target_url,
                      slo_default_relay_state: saml_config.base_url,
                      idp_cert: File.read('./saml.crt'),
                      attribute_service_name: 'Mumuki',
                      request_attributes: [
                          {name: 'email', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Email address'},
                          {name: 'name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Full name'},
                          {name: 'image', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Avatar image'}
                      ],
                      attribute_statements: {
                          name: [saml_config.translaton_name],
                          email: [saml_config.translaton_email],
                          image: [saml_config.translaton_image]
                      }
  end

  def configure_rails_forgery_protection!(_controller_class)
    # FIXME this is big security issue
    # Do nothing (do not protect): the IdP calls the assertion_url via POST and without the CSRF token
  end

  def logout_redirection_path
    "#{auth_path}/spslo"
  end
end

class Mumukit::Login::Provider::Auth0 < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :auth0,
                      auth0_config.client_id,
                      auth0_config.client_secret,
                      auth0_config.domain,
                      callback_path: callback_path
  end

  def request_authentication!(controller, login_settings)
    settings = lock_settings(controller, login_settings, {closable: false})
    controller.render_html! <<HTML
 <script type="text/javascript">
      new Auth0Lock('#{auth0_config.client_id}', '#{auth0_config.domain}').show(#{settings});
  </script>
HTML
  end

  def header_html(*)
    <<HTML
<script src="https://cdn.auth0.com/js/lock-7.12.min.js"></script>
</script>
HTML
  end

  def footer_html(*)
    '<a href="https://auth0.com/" target="_blank">
        <img height="40" alt="JWT Auth for open source projects" src="//cdn.auth0.com/oss/badges/a0-badge-light.png"/>
     </a>'
  end

  private

  def auth0_config
    Mumukit::Login.config.auth0
  end

  def lock_settings(controller, login_settings, options)
    login_settings.to_lock_json(controller.url_for(callback_path), options)
  end
end

class Mumukit::Login::Provider::Developer < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :developer
  end

  def configure_rails_forgery_protection!(*)
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
