module Mumukit::Login::LoginSettingsHelpers
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
