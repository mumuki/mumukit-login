class Mumukit::Login::Provider::Google < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :google_oauth2,
                      google_config.client_id,
                      google_config.client_secret
  end

  def name
    'google_oauth2'
  end

  private

  def google_config
    Mumukit::Login.config.google
  end
end
