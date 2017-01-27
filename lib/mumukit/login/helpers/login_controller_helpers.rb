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