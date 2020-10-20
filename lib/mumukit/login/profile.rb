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
      image_url: image_url(omniauth.info.image)
    }.compact
  end

  def self.image_url(url)
    url if url.try { size <= 255 }
  end

  def self.generate_uid(omniauth)
    Mumukit::Login::Provider.parse_login_provider(omniauth.provider).uid_for_profile(omniauth)
  end
end
