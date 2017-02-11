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
    mumukit_controller.shared_session.uid
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