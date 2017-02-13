require 'base64'

class Mumukit::Login::MucookieSharedSession

  def initialize(mucookie)
    @mucookie = mucookie
  end

  def uid
    @mucookie.decrypt_and_read :session
  end

  def uid=(uid)
    @mucookie.encrypt_and_write! :session, uid, httponly: true
  end

  def profile
    JSON.parse @mucookie.decode_and_read(:profile)
  end

  def profile=(profile)
    @mucookie.encode_and_write! :profile, profile.to_json
  end

  def current_organization_name=(organization_name)
    @mucookie.write! :organization, organization_name
  end

  def clear!
    @mucookie.delete! :profile
    @mucookie.delete! :organization
    @mucookie.delete! :session
  end

  private

  def decode_session(uid)
  end

  def decode_token(uid)
    Mumukit::Auth::Token.encode uid, {exp: Mumukit::Login.config.session_duration.days.from_now}, encoding_client
  end

end
