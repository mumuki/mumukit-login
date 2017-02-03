module Mumukit::Login::LoginControllerHelpers

  def login_current_user!
    origin_redirector.save_location!
    if current_user?
      origin_redirector.redirect!
    else
      login_provider.request_authentication! mumukit_controller, login_settings
    end
  end

  def callback_current_user!
    profile = Mumukit::Login::Profile.from_omniauth(env['omniauth.auth'])
    user = Mumukit::Login.config.user_class.for_profile profile
    save_current_user_session! user
    origin_redirector.redirect!
  end

  def logout_current_user!
    destroy_current_user_session!
    mumukit_controller.redirect! login_provider.logout_redirection_path
  end

  private

  # default
  def destroy_current_user_session!
    mumukit_controller.current_user_store.clear!
  end

  # default
  def save_current_user_session!(user)
    mumukit_controller.current_user_store.set! user.uid,
                                               user_name: user.name,
                                               user_image_url: user.image_url
  end
end
