
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

  def to_lock_json(callback_url, options={})
    lock_json
        .merge(callbackURL: callback_url, responseType: 'code', authParams: {scope: 'openid profile'})
        .merge(options)
        .to_json
        .html_safe
  end

  def lock_json
    {dict: I18n.locale,
     connections: lock_login_methods,
     icon: '/logo-alt.png',
     socialBigButtons: !many_methods?,
     disableResetAction: false}
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