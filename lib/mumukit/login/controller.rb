class Mumukit::Login::Controller
  def initialize(framework, native)
    @framework = framework
    @native = native
  end

  def current_user_store
    if env['HTTP_AUTHORIZATION']
      Mumukit::Login::JWTCurrentUserStore.new self
    else
      Mumukit::Login::SessionCurrentUserStore.new self
    end
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

  def url_for(path)
    URI.join(request.base_url, path).to_s
  end

  def request
    Rack::Request.new(env)
  end

  def session
    request.session
  end

  def cookies
    @framework.cookies @native
  end
end