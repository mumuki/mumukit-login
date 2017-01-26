class Mumukit::Login::Controller
  def initialize(framework, native)
    @framework = framework
    @native = native
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

  def request
    Rack::Request.new(env)
  end

  def url_for(path)
    URI.join(request.base_url, path).to_s
  end

  def session
    request.session
  end
end