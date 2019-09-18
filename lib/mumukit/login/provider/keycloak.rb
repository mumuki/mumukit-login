class Mumukit::Login::Provider::Keycloak < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :keycloak, setup: setup_proc
  end

  private

  def default_settings
    Mumukit::Login.config.google
  end
end
