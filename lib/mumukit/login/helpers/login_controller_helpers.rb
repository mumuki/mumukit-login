module Mumukit::Login::LoginControllerHelpers

  def login_current_user!
    origin_redirector.save_after_login_location!
    if current_user?
      origin_redirector.redirect_after_login!
    else
      login_provider.request_authentication! mumukit_controller, login_settings
    end
  end

  def callback_current_user!
    profile = Mumukit::Login::Profile.from_omniauth(mumukit_controller.env['omniauth.auth'])
    user = Mumukit::Login.config.user_class.for_profile profile
    save_current_user_session! user
    origin_redirector.redirect_after_login!
  end

  def logout_current_user!
    destroy_current_user_session!
    origin_redirector.redirect_after_logout!
  end

  private

  # default
  def destroy_current_user_session!
    mumukit_controller.session.clear
    mumukit_controller.shared_session.clear!
  end

  # default
  def save_current_user_session!(user)
    mumukit_controller.shared_session.tap do |it|
      it.uid = user.uid
      it.profile = {user_name: user.name,
                    user_image_url: user.image_url}
    end
  end
end
