class Mumukit::Login::Provider::Oauth2 < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :oauth2, setup: setup_proc
  end
end
