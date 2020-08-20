module Mumukit::Login::Profile
  def self.from_omniauth(omniauth)
    struct profile_hash(omniauth)
  end

  def self.profile_hash(omniauth)
    {
      provider: omniauth.provider,
      first_name: omniauth.info.first_name,
      last_name: omniauth.info.last_name,
      social_id: omniauth.uid,
      email: omniauth.info.email,
      uid: generate_uid(omniauth),
      image_url: omniauth.info.image,
      email_verified: omniauth.extra.raw_info.email_verified
    }.compact
  end

  def self.generate_uid(omniauth)
    omniauth.uid || omniauth.info.email
  end
end
