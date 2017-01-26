module Mumukit::Login::Profile
  def self.from_omniauth(omniauth)
    struct provider: omniauth.provider,
           name: omniauth.info.nickname || omniauth.info.name,
           social_id: omniauth.uid,
           email: omniauth.info.email,
           uid: omniauth.info.email || omniauth.uid,
           image_url: omniauth.info.image
  end
end