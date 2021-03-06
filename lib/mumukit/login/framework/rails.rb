module Mumukit::Platform::WebFramework::Rails
  def self.env(rails_controller)
    rails_controller.request.env
  end

  def self.write_cookie!(key, value, rails_controller)
    rails_controller.instance_eval do
      cookies[key] = value
    end
  end

  def self.delete_cookie!(key, domain, rails_controller)
    rails_controller.instance_eval do
      cookies.delete key, domain: domain
    end
  end

  def self.read_cookie(key, rails_controller)
    rails_controller.instance_eval do
      cookies[key]
    end
  end

  def self.redirect!(path, rails_controller)
    rails_controller.redirect_to path
  end

  def self.render_html!(html, rails_controller)
    rails_controller.render html: html[:body].html_safe, layout: true
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
      rails_router.match 'auth/:provider/callback' => :callback_current_user, via: [:get, :post]
      rails_router.get 'auth/failure' => :login_failure
      rails_router.get 'logout' => :logout_current_user
      rails_router.get 'login' => :login_current_user
    end
  end

  def self.configure_login_controller!(controller_class)
    controller_class.class_eval do
      include Mumukit::Login::LoginControllerHelpers

      %w(callback_current_user login_failure logout_current_user login_current_user).each do |method|
        define_method method do
          self.send "#{method}!"
        end
      end
    end
  end

  # Configures forgery protection and mixes authentication methods.
  #
  # @param [ActionController::Base::Class] controller_class
  #
  def self.configure_controller!(controller_class)
    controller_class.class_eval do
      include Mumukit::Login::AuthenticationHelpers
      include Mumukit::Login::AuthorizationHelpers

      helper_method :current_user,
                    :current_user?,
                    :current_user_uid,
                    :mumukit_controller,
                    :login_form

    end
  end
end