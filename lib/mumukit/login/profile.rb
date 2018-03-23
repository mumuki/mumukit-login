module Mumukit::Login::Profile
  def self.from_omniauth(omniauth)
    struct provider: omniauth.provider,
           first_name: omniauth.info.first_name,
           last_name: omniauth.info.last_name,
           social_id: omniauth.uid,
           email: omniauth.info.email,
           uid: omniauth.info.email || omniauth.uid,
           image_url: omniauth.info.image
  end
end
