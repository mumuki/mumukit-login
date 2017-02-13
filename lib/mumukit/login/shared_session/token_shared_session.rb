class Mumukit::Login::TokenSharedSession
  def initialize(env)
    @env = env
  end

  def uid
    token.uid
  end

  %w(uid= profile= current_organization_name= clear!).each do |it|
    define_method it do
      raise 'JWT tokens are read-only'
    end
  end

  def token
    @token ||= Mumukit::Auth::Token.decode_header(authorization_header).tap(&:verify_client!)
  end

  def authorization_header
    @env['HTTP_AUTHORIZATION']
  end
end
