class Mumukit::Login::OriginRedirector
  def initialize(controller)
    @controller = controller
  end

  def redirect!
    @controller.redirect!(@controller.session[:redirect_after_login] || '/')
  end

  def save_location!
    @controller.session[:redirect_after_login] = Addressable::URI.heuristic_parse(origin).path
  end

  private

  def origin
    @controller.request.params['origin']
  end
end