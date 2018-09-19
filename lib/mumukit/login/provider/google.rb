class Mumukit::Login::Provider::Google < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :google_oauth2, setup: setup_proc
  end

  def name
    'google_oauth2'
  end

  private

  def default_settings
    Mumukit::Login.config.google
  end
end
