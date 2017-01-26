class Mumukit::Login::Provider::Developer < Mumukit::Login::Provider::Base
  def configure_omniauth!(omniauth)
    omniauth.provider :developer
  end

  def configure_rails_forgery_protection!(*)
  end
end
