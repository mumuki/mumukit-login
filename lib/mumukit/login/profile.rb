module Mumukit::Login::Profile
  def self.from_omniauth(omniauth)
    struct provider: omniauth.provider,
           first_name: omniauth.info.first_name,
           last_name: omniauth.info.last_name,
           social_id: omniauth.uid,
           email: omniauth.info.email,
           uid: generate_uid(omniauth),
           image_url: omniauth.info.image
  end

  def self.generate_uid(omniauth)
    omniauth.info.email || omniauth.uid
  end
end
