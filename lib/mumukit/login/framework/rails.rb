module Mumukit::Login::Framework::Rails

  def self.env(rails_controller)
    rails_controller.request.env
  end

  def self.redirect!(path, rails_controller)
    rails_controller.redirect_to path
  end

  def self.render_html!(content, rails_controller)
    rails_controller.render html: content.html_safe, layout: true
  end

  # Configures the login routes.
  # This method should be used this way:
  #
  #  controller :sessions do
  #    Mumukit::Login.configure_session_controller_routes! self
  #  end
  #
  # @param [RailsRouter] rails_router
  #
  def self.configure_login_routes!(rails_router)
    rails_router.controller :login do
      rails_router.match 'auth/:provider/callback' => :callback, via: [:get, :post], as: 'auth_callback'
      rails_router.get 'auth/failure' => :failure
      rails_router.get 'logout' => :destroy
      rails_router.get 'login' => :login
    end
  end

  def self.configure_login_controller!(controller_class)
    controller_class.class_eval do
      include Mumukit::Login::LoginControllerHelpers
    end
  end

  # Configures forgery protection and mixes authentication methods.
  #
  # @param [ActionController::Base::Class] controller_class
  #
  def self.configure_controller!(controller_class)
    Mumukit::Login.config.provider.configure_rails_forgery_protection!(controller_class)
    controller_class.class_eval do
      include Mumukit::Login::AuthenticationHelpers

      helper_method :current_user,
                    :current_user?,
                    :current_user_uid,
                    :mumukit_controller,
                    :login_form

    end
  end
end