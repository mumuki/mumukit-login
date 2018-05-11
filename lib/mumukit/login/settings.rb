class Mumukit::Login::Settings
  LOCK_LOGIN_METHODS = {
      facebook: 'facebook',
      github: 'github',
      google: 'google-oauth2',
      twitter: 'twitter',
      user_pass: 'Username-Password-Authentication'
  }

  attr_accessor :login_methods

  def initialize(login_methods = Mumukit::Login::Settings.default_methods)
    @login_methods = login_methods.map(&:to_sym)
  end

  def many_methods?
    user_pass? && social_login_methods.size > 1
  end

  def user_pass?
    login_methods.include? :user_pass
  end

  def social_login_methods
    login_methods - [:user_pass]
  end

  def to_lock_json(callback_url, locale, options={})
    lock_json_spec
        .merge(
            auth: {
                redirect: true,
                redirectUrl: callback_url
            },
            params: {
                locale: locale
            },
            responseType: 'code',
            authParams: {scope: 'openid profile'})
        .merge(options)
        .to_json
        .html_safe
  end

  def lock_json_spec
    {
        languageDictionary: {
            title: 'Mumuki',
            signUpTerms: I18n.t(:accept_terms_and_conditions, terms_url: Mumukit::Login.config.terms_url)
        },
        mustAcceptTerms: true,
        language: Mumukit::Platform::Locale.get_spec_for(I18n.locale, :auth0_code),
        allowedConnections: lock_login_methods,
        socialButtonStyle: many_methods? ? 'small' : 'big',
        rememberLastLogin: true,
        theme: {
            logo: Mumukit::Login.config.logo_url,
            primaryColor: '#FF5B81'
        },
        disableResetAction: false,
        configurationBaseUrl: 'https://cdn.auth0.com',
        closable: false}
  end

  def lock_login_methods
    login_methods.map { |it| LOCK_LOGIN_METHODS[it] }
  end

  def self.login_methods
    LOCK_LOGIN_METHODS.keys
  end

  def self.default_methods
    [:user_pass]
  end
end

class Mumukit::Platform::Organization::Settings < Mumukit::Platform::Model
  def login_settings
    @login_settings ||= Mumukit::Login::Settings.new(login_methods)
  end

  def customized_login_methods?
    login_methods.size < Mumukit::Login::Settings.login_methods.size
  end

  def inconsistent_public_login?
    customized_login_methods? && public?
  end
end
