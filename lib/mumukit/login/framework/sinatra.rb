module Mumukit::Platform::WebFramework::Sinatra
  def self.env(sinatra_handler)
    sinatra_handler.request.env
  end

  def self.write_cookie!(key, value, sinatra_handler)
    sinatra_handler.response.set_cookie key, value
  end

  def self.delete_cookie!(key, domain, sinatra_handler)
    sinatra_handler.response.delete_cookie key, domain: domain
  end

  def self.read_cookie(key, sinatra_handler)
    sinatra_handler.request.cookies[key]
  end

  def self.redirect!(path, sinatra_handler)
    sinatra_handler.redirect path
  end

  def self.render_html!(html, sinatra_handler)
<<HTML
<html>
  <head>#{html[:header]}</head>
  <body>#{html[:body]}</body>
</html>
HTML
  end

  def self.configure_login_routes!(sinatra_module)
    sinatra_module.instance_eval do
      auth_callback = proc { callback_current_user! }
      get '/auth/:provider/callback', &auth_callback
      post '/auth/:provider/callback', &auth_callback
      get('/auth/failure') { login_failure! }
      get('/logout') { logout_current_user! }
      get('/login') { login_current_user! }
    end
  end


  def self.configure_login_controller!(sinatra_helpers)
    sinatra_helpers.instance_eval do
      include Mumukit::Login::LoginControllerHelpers
    end
  end

  def self.configure_controller!(sinatra_helpers)
    sinatra_helpers.instance_eval do
      include Mumukit::Login::AuthenticationHelpers
      include Mumukit::Login::AuthorizationHelpers
    end
  end
end