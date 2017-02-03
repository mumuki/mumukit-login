module Mumukit::Login::Framework::Sinatra

  def self.env(sinatra_handler)
    sinatra_handler.request.env
  end

  def self.redirect!(path, sinatra_handler)
    sinatra_handler.redirect path
  end

  def self.render_html!(content, sinatra_handler)
    content
  end

  def self.configure_login_routes!(sinatra_module)
    sinatra_module.class_eval do
      auth_callback = proc { callback_current_user! }
      get '/auth/:provider/callback', &auth_callback
      post '/auth/:provider/callback', &auth_callback
      get('/auth/failure') { login_failure! }
      get('/logout') { logout_current_user! }
      get('/login') { login_current_user! }
    end
  end


  def self.configure_login_controller!(sinatra_helpers)
    sinatra_helpers.class_eval do
      include Mumukit::Login::LoginControllerHelpers
    end
  end

  def self.configure_controller!(sinatra_helpers)
    sinatra_helpers.class_eval do
      include Mumukit::Login::AuthenticationHelpers
      include Mumukit::Login::AuthorizationHelpers
    end
  end
end