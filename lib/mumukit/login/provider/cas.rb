class Mumukit::Login::Provider::Cas < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :cas,
                      url: cas_config.url,
                      host: cas_config.host,
                      ca_path: '.',
                      disable_ssl_verification: true # FIXME this is big security issue
  end

  private

  def cas_config
    Mumukit::Login.config.cas
  end
end
