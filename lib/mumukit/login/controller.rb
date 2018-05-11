class Mumukit::Login::Controller
  def initialize(framework, native)
    @framework = framework
    @native = native
  end

  def shared_session
    if env['HTTP_AUTHORIZATION']
      Mumukit::Login::TokenSharedSession.new env
    else
      Mumukit::Login::MucookieSharedSession.new mucookie
    end
  end

  def current_organization
    Mumukit::Platform::Organization.current
  end

  def mucookie
    @mucookie ||= Mumukit::Login::Mucookie.new self
  end

  def url_for(path)
    URI.join(request.base_url, path).to_s
  end

  def request
    Rack::Request.new(env)
  end

  def session
    request.session
  end

  def env
    @framework.env @native
  end

  def redirect!(path)
    @framework.redirect!(path, @native)
  end

  def render_html!(html)
    @framework.render_html!(html, @native)
  end

  def write_cookie!(key, value)
    @framework.write_cookie! key, value, @native
  end

  def read_cookie(key)
    @framework.read_cookie key, @native
  end

  def delete_cookie!(key, domain)
    @framework.delete_cookie! key, domain, @native
  end
end
