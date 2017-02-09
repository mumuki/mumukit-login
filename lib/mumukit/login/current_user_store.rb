class Mumukit::Login::SessionCurrentUserStore
  def initialize(controller)
    @controller = controller
  end

  def get_uid
    puts "COOKIES: #{@controller.session.as_json}"
    puts "UID: #{@controller.session[:user_uid]}"
    @controller.session[:user_uid]
  end

  def clear!
    @controller.session[:user_uid] = nil
  end

  def set!(uid, values)
    @controller.session[:user_uid] = uid
    @controller.cookies[:mucookie] = values.to_json
  end
end

class Mumukit::Login::JWTCurrentUserStore
  def initialize(controller)
    @controller = controller
  end

  def get_uid
    token.uid
  end

  def clear!
    raise 'JWT tokens are read-only'
  end

  def set!(*)
    raise 'JWT tokens are read-only'
  end

  def token
    @token ||= Mumukit::Auth::Token.decode_header(authorization_header).tap(&:verify_client!)
  end

  def authorization_header
    @controller.env['HTTP_AUTHORIZATION']
  end
end
