class Mumukit::Login::OriginRedirector
  def initialize(controller)
    @controller = controller
  end

  def redirect_after_login!
    location = @controller.session[:redirect_after_login]
    @controller.session[:redirect_after_login] = nil
    @controller.redirect!(location || '/')
  end

  def redirect_after_logout!
    @controller.redirect! origin
  end

  def save_location!
    @controller.session[:redirect_after_login] = origin
  end

  private

  def origin
    Addressable::URI.heuristic_parse(@controller.request.params['origin'] || '/').to_s
  end
end